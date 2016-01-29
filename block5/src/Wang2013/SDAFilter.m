classdef SDAFilter<handle % Stack Denoising Autoencoder filter (it also uses a Neural Network for classification)
    % atributos
    properties(Access = private)
        a
        p
        opt
        opts
        tmpl
        param
        paramOld
        param0
        pos
        nn
        reportRes
        scaleHeight
        scaleWidth
        framesProcessed
        drawopt
    end
    
    methods
        % Constructor
        % firstFrame: first frame of the sequence for initializing purobj.poses
        % p: bounding box indicating the selected object to track [xmin, ymin,
        % width, height]
        function obj = SDAFilter(firstFrame, p)   
            % Convert from [xmin, ymin, width, height] to
            % [xcenter, ycenter, width, height]
            obj.p = [p(1)+p(3)/2, p(2)+p(4)/2, p(3), p(4), 0];
            obj.framesProcessed = 0;
            
            % Add to path needed functions
            addpath(genpath('bin'))
            
            % Other not so important obj.parameters that need to be initialized
            obj.opt = obj.initializeOpt();
            
            % Initialize stuff before starting to estimate new frames
            obj = obj.initializeDLT(firstFrame);
        end
        
        function opt = initializeOpt(obj)
            opt = struct('numsample',1000, 'affsig',[4, 4,.05,.00,.001,.00]);
            opt.useGpu = true;
            opt.maxbasis = 10;
            opt.updateThres = 0.8; 
            opt.condenssig = 0.01;
            opt.tmplsize = [32, 32];
            opt.normalWidth = 320;
            opt.normalHeight = 240;   
        end
        
        function obj = initializeDLT(obj, frame)
            rand('state',0);  randn('state',0);
            
            if size(frame,3)==3
                frame = double(rgb2gray(frame));
            end

            obj.scaleHeight = size(frame, 1) / obj.opt.normalHeight;
            obj.scaleWidth = size(frame, 2) / obj.opt.normalWidth;
            obj.p(1) = obj.p(1) / obj.scaleWidth;
            obj.p(3) = obj.p(3) / obj.scaleWidth;
            obj.p(2) = obj.p(2) / obj.scaleHeight;
            obj.p(4) = obj.p(4) / obj.scaleHeight;
            frame = imresize(frame, [obj.opt.normalHeight, obj.opt.normalWidth]);
            frame = double(frame) / 255;

            obj.paramOld = [obj.p(1), obj.p(2), obj.p(3)/obj.opt.tmplsize(2), obj.p(5), obj.p(4) /obj.p(3) / (obj.opt.tmplsize(1) / obj.opt.tmplsize(2)), 0];
            obj.param0 = affparam2mat(obj.paramOld);

            if ~isfield(obj.opt,'minopt')
              obj.opt.minopt = optimset; obj.opt.minopt.MaxIter = 25; obj.opt.minopt.Display='off';
            end
            obj.reportRes = [];
            obj.tmpl.mean = warpimg(frame, obj.param0, obj.opt.tmplsize);
            obj.tmpl.basis = [];
            % Sample 10 obj.positive templates for initialization
            for i = 1 : obj.opt.maxbasis / 10
                obj.tmpl.basis(:, (i - 1) * 10 + 1 : i * 10) = samplePos_DLT(frame, obj.param0, obj.opt.tmplsize);
            end
            % Sample 100 negative templates for initialization
            p0 = obj.paramOld(5);
            obj.tmpl.basis(:, obj.opt.maxbasis + 1 : 100 + obj.opt.maxbasis) = sampleNeg(frame, obj.param0, obj.opt.tmplsize, 100, obj.opt, 8);

            obj.param.est = obj.param0;
            obj.param.lastUpdate = 1;

            wimgs = [];


            % track the sequence from frame 2 onward
            L = [ones(obj.opt.maxbasis, 1); (-1) * ones(100, 1)];
            obj.nn = initDLT(obj.tmpl, L);
            L = [];
            obj.pos = obj.tmpl.basis(:, 1 : obj.opt.maxbasis);
            obj.pos(:, obj.opt.maxbasis + 1) = obj.tmpl.basis(:, 1);
            obj.opts.numepochs = 5 ; 
            %obj.drawopt = drawtrackresult([], 0, frame, obj.tmpl, obj.param, []);
        end
        
        function [obj, bb, bbCenter, results] = estimatePosition(obj, frame)            
            % (Lines 75 to 120 of run_DLT.m)
            obj.framesProcessed = obj.framesProcessed + 1;
            if size(frame,3)==3
                frame = double(rgb2gray(frame));
            end  
            frame = imresize(frame, [obj.opt.normalHeight, obj.opt.normalWidth]);
            frame = double(frame) / 255;

            % do tracking
            obj.param = estwarp_condens_DLT(frame, obj.tmpl, obj.param, obj.opt, obj.nn, obj.framesProcessed);

            % do update

            temp = warpimg(frame, obj.param.est', obj.opt.tmplsize);
            obj.pos(:, mod(obj.framesProcessed - 1, obj.opt.maxbasis) + 1) = temp(:);
            if  obj.param.update
                obj.opts.batchsize = 10;
                % Sample two set of negative samples at different range.
                neg = sampleNeg(frame, obj.param.est', obj.opt.tmplsize, 49, obj.opt, 8);
                neg = [neg sampleNeg(frame, obj.param.est', obj.opt.tmplsize, 50, obj.opt, 4)];
                obj.nn = nntrain(obj.nn, [obj.pos neg]', [ones(obj.opt.maxbasis + 1, 1); zeros(99, 1)], obj.opts);
            end
            
            res = affparam2geom(obj.param.est);
            obj.p(1) = round(res(1));
            obj.p(2) = round(res(2)); 
            obj.p(3) = round(res(3) * obj.opt.tmplsize(2));
            obj.p(4) = round(res(5) * (obj.opt.tmplsize(1) / obj.opt.tmplsize(2)) * obj.p(3));
            obj.p(5) = res(4);
            obj.p(1) = obj.p(1) * obj.scaleWidth;
            obj.p(3) = obj.p(3) * obj.scaleWidth;
            obj.p(2) = obj.p(2) * obj.scaleHeight;
            obj.p(4) = obj.p(4) * obj.scaleHeight;
            obj.paramOld = [obj.p(1), obj.p(2), obj.p(3)/obj.opt.tmplsize(2), obj.p(5), obj.p(4) /obj.p(3) / (obj.opt.tmplsize(1) / obj.opt.tmplsize(2)), 0];

            obj.reportRes = [obj.reportRes;  affparam2mat(obj.paramOld)];
            
            obj.tmpl.basis = obj.pos;
            results.res=obj.reportRes;
            results.type='ivtAff';
            results.tmplsize = obj.opt.tmplsize;
%             obj.drawopt = drawtrackresult(obj.drawopt, obj.framesProcessed, frame, obj.tmpl, obj.param, []);
            [bb, bbCenter] = obj.obtainBB(size(obj.tmpl.mean), obj.param.est);
           
        end
        
        function [bb, center] = obtainBB(obj, sz, p)
            h = sz(1); w = sz(2); %h = sz(1); w = sz(2); ??
            M = [p(1) p(3) p(4); p(2) p(5) p(6)];
            corners = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2; 1,-w/2,-h/2 ]';
            corners = M * corners;
            % corner(1,1) -> top left X
            % corner(2,1) -> top left Y
            % corner(:,2) -> top right corner
            % corner(:,3) -> bottom right corner
            % corner(:,4) -> bottom left corner
            % corner(:,5) -> top left corner (again)
            % bb format: x top left, y top left, width and height
            bb = [corners(1,1), corners(2,1), corners(1,2) - corners(1,1), corners(2,3) - corners(2,2)];
            center = mean(corners(:,1:4),2);
        end
    end
end