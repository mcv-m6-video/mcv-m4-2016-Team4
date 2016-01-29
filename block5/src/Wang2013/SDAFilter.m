classdef SDAFilter % Stack Denoising Autoencoder filter (it also uses a Neural Network for classification)
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
        % firstFrame: first frame of the sequence for initializing purself.poses
        % p: bounding box indicating the selected object to track [xmin, ymin,
        % width, height]
        function self = SDAFilter(firstFrame, p)   
            % Convert from [xmin, ymin, width, height] to
            % [xcenter, ycenter, width, height]
            self.p = [p(1)+p(3)/2, p(2)+p(4)/2, p(3), p(4), 0];
            self.framesProcessed = 0;
            
            % Add to path needed functions
            addpath(genpath('bin'))
            
            % Other not so important self.parameters that need to be initialized
            self.opt = self.initializeOpt();
            
            % Initialize stuff before starting to estimate new frames
            self = self.initializeDLT(firstFrame);
        end
        
        function opt = initializeOpt(self)
            opt = struct('numsample',1000, 'affsig',[4, 4,.05,.00,.001,.00]);
            opt.useGpu = true;
            opt.maxbasis = 10;
            opt.updateThres = 0.8; 
            opt.condenssig = 0.01;
            opt.tmplsize = [32, 32];
            opt.normalWidth = 320;
            opt.normalHeight = 240;   
        end
        
        function self = initializeDLT(self, frame)
            rand('state',0);  randn('state',0);
            
            if size(frame,3)==3
                frame = double(rgb2gray(frame));
            end

            self.scaleHeight = size(frame, 1) / self.opt.normalHeight;
            self.scaleWidth = size(frame, 2) / self.opt.normalWidth;
            self.p(1) = self.p(1) / self.scaleWidth;
            self.p(3) = self.p(3) / self.scaleWidth;
            self.p(2) = self.p(2) / self.scaleHeight;
            self.p(4) = self.p(4) / self.scaleHeight;
            frame = imresize(frame, [self.opt.normalHeight, self.opt.normalWidth]);
            frame = double(frame) / 255;

            self.paramOld = [self.p(1), self.p(2), self.p(3)/self.opt.tmplsize(2), self.p(5), self.p(4) /self.p(3) / (self.opt.tmplsize(1) / self.opt.tmplsize(2)), 0];
            self.param0 = affparam2mat(self.paramOld);

            if ~isfield(self.opt,'minopt')
              self.opt.minopt = optimset; self.opt.minopt.MaxIter = 25; self.opt.minopt.Display='off';
            end
            self.reportRes = [];
            self.tmpl.mean = warpimg(frame, self.param0, self.opt.tmplsize);
            self.tmpl.basis = [];
            % Sample 10 self.positive templates for initialization
            for i = 1 : self.opt.maxbasis / 10
                self.tmpl.basis(:, (i - 1) * 10 + 1 : i * 10) = samplePos_DLT(frame, self.param0, self.opt.tmplsize);
            end
            % Sample 100 negative templates for initialization
            p0 = self.paramOld(5);
            self.tmpl.basis(:, self.opt.maxbasis + 1 : 100 + self.opt.maxbasis) = sampleNeg(frame, self.param0, self.opt.tmplsize, 100, self.opt, 8);

            self.param.est = self.param0;
            self.param.lastUpdate = 1;

            wimgs = [];


            % track the sequence from frame 2 onward
            L = [ones(self.opt.maxbasis, 1); (-1) * ones(100, 1)];
            self.nn = initDLT(self.tmpl, L);
            L = [];
            self.pos = self.tmpl.basis(:, 1 : self.opt.maxbasis);
            self.pos(:, self.opt.maxbasis + 1) = self.tmpl.basis(:, 1);
            self.opts.numepochs = 5 ; 
            %self.drawopt = drawtrackresult([], 0, frame, self.tmpl, self.param, []);
        end
        
        function [self, bb, bbCenter, results] = estimatePosition(self, frame)            
            % (Lines 75 to 120 of run_DLT.m)
            self.framesProcessed = self.framesProcessed + 1;
            if size(frame,3)==3
                frame = double(rgb2gray(frame));
            end  
            frame = imresize(frame, [self.opt.normalHeight, self.opt.normalWidth]);
            frame = double(frame) / 255;

            % do tracking
            self.param = estwarp_condens_DLT(frame, self.tmpl, self.param, self.opt, self.nn, self.framesProcessed);

            % do update

            temp = warpimg(frame, self.param.est', self.opt.tmplsize);
            self.pos(:, mod(self.framesProcessed - 1, self.opt.maxbasis) + 1) = temp(:);
            if  self.param.update
                self.opts.batchsize = 10;
                % Sample two set of negative samples at different range.
                neg = sampleNeg(frame, self.param.est', self.opt.tmplsize, 49, self.opt, 8);
                neg = [neg sampleNeg(frame, self.param.est', self.opt.tmplsize, 50, self.opt, 4)];
                self.nn = nntrain(self.nn, [self.pos neg]', [ones(self.opt.maxbasis + 1, 1); zeros(99, 1)], self.opts);
            end
            
            res = affparam2geom(self.param.est);
            self.p(1) = round(res(1));
            self.p(2) = round(res(2)); 
            self.p(3) = round(res(3) * self.opt.tmplsize(2));
            self.p(4) = round(res(5) * (self.opt.tmplsize(1) / self.opt.tmplsize(2)) * self.p(3));
            self.p(5) = res(4);
            self.p(1) = self.p(1) * self.scaleWidth;
            self.p(3) = self.p(3) * self.scaleWidth;
            self.p(2) = self.p(2) * self.scaleHeight;
            self.p(4) = self.p(4) * self.scaleHeight;
            self.paramOld = [self.p(1), self.p(2), self.p(3)/self.opt.tmplsize(2), self.p(5), self.p(4) /self.p(3) / (self.opt.tmplsize(1) / self.opt.tmplsize(2)), 0];

            self.reportRes = [self.reportRes;  affparam2mat(self.paramOld)];
            
            self.tmpl.basis = self.pos;
            results.res=self.reportRes;
            results.type='ivtAff';
            results.tmplsize = self.opt.tmplsize;
%             self.drawopt = drawtrackresult(self.drawopt, self.framesProcessed, frame, self.tmpl, self.param, []);
            [bb, bbCenter] = self.obtainBB(size(self.tmpl.mean), self.param.est);
           
        end
        
        function [bb, center] = obtainBB(self, sz, p)
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