classdef ParticleFilter
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
    end
    
    methods
        % Constructor
        % firstFrame: first frame of the sequence for initializing purself.poses
        % p: bounding box indicating the selfect to track [xmin, ymin,
        % width, height]
        function self = ParticleFilter(firstFrame, p)   
            self.p = [p(1)+p(3)/2, p(2)+p(4)/2, p(3), p(4), 0];
            
            % Other not so important self.parameters that need to be initialized
            self.opt = self.initializeOpt();
            
            % Initialize stuff to start estimating frames
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
            addpath('affineUtility');
            addpath('drawUtility');
            addpath('imageUtility');
            addpath('nn');
            rand('state',0);  randn('state',0);
            
            if size(frame,3)==3
                frame = double(rgb2gray(frame));
            end

            scaleHeight = size(frame, 1) / self.opt.normalHeight;
            scaleWidth = size(frame, 2) / self.opt.normalWidth;
            self.p(1) = self.p(1) / scaleWidth;
            self.p(3) = self.p(3) / scaleWidth;
            self.p(2) = self.p(2) / scaleHeight;
            self.p(4) = self.p(4) / scaleHeight;
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
        end
        
        function estimatePosition(frame)
           % TODO (lines 75 to 120 of run_DLT.m)
        end
    end
end