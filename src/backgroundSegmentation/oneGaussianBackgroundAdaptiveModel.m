classdef oneGaussianBackgroundAdaptiveModel<handle
    properties(Access = private)
        alpha
        rho
        colorTransform
        colorInverseTransform
        colorIm
        morphoFunction
        shadowRemove
        
        mu
        sigma_square
    end
    
    methods
        % Creamos el modelo de deteccion de foreground
        function obj = oneGaussianBackgroundAdaptiveModel(alpha, rho, colorIm, colorTransform, ...
                morphoFunction, shadowRemove)
            % Sino existen las variables las declaramos
            if ~exist('alpha', 'var')
                alpha = 2.5;
            end
            
            if ~exist('rho', 'var')
                rho = 0.1;
            end
            
            colorInverseTransform = false;
            if ~exist('colorTransform', 'var')
                colorTransform = @(x) x;
                colorInverseTransform = @(x) x;
            else
                if length(colorTransform) > 1
                    colorInverseTransform = colorTransform{2};
                    colorTransform = colorTransform{1};
                end

            end
            if ~exist('colorIm', 'var')
                colorIm = false;
            end

            if ~exist('morphoFunction', 'var')
                morphoFunction = @(x)x;
            end

            if ~exist('shadowRemove', 'var')
                shadowRemove = false;
            end
            
            % Asignamos las variables
            obj.alpha = alpha;
            obj.rho = rho;
            obj.colorTransform = colorTransform;
            obj.colorInverseTransform = colorInverseTransform;
            obj.colorIm = colorIm;
            obj.morphoFunction = morphoFunction;
            obj.shadowRemove = shadowRemove;
        end
        
        % Aprendemos
        function learn(obj, masks)
            if obj.colorIm
                cumpixel = cell(1,3);
            else
                cumpixel = cell(1,1);
            end

            for i = 1:size(masks,4)
                im = masks(:,:,:,i);
                if ~obj.colorIm
                    if size(im,3)>1
                        im = rgb2gray( im );
                    end
                else
                    im = obj.colorTransform( im );
                end
                im = double( im );
                for j = 1:size(im,3)
                    cumpixel{j} = cat(3 , cumpixel{j} , im(:,:,j) );
                end
            end % for

            muAux = cellfun(@(x) mean(x,3), cumpixel, 'UniformOutput', false);
            sigmaAux = cellfun(@(x) var(x , 0 , 3), cumpixel, 'UniformOutput', false);

            % Conversion from cell to matrix
            obj.mu = []; obj.sigma_square = [];
            for i = 1:length(muAux)
                obj.mu = cat(3 , obj.mu , muAux{i} );
                obj.sigma_square = cat(3 , obj.sigma_square , sigmaAux{i} );
            end
        end
        
        % Aplicamos el modelo a las imagenes entrantes
        function segmentedMasks = detectForeground(obj, images)
            % Read image to know size of the masks
            segmentedMasks = false(size(images,1), size(images,2), size(images,4));
            
            count = 1;
            for i = 1:size(images, 4)
                % Adapt the mu and sigma
                sigma = sqrt(obj.sigma_square);
                % Prevent low values of sigma
                sigma_plus2 = sigma + 2;
                im = images(:,:,:,i);
                imOrig = im;
                if ~obj.colorIm
                    if size(im,3)>1
                        im = rgb2gray( im );
                    end
                else
                    im = obj.colorTransform( im );
                end
                im = double( im );
                % background --> 0      foreground --> 1
                background = ~(abs(im - obj.mu) < (obj.alpha*sigma_plus2));

                % In case of color images, if any dimension falls outside the
                % gaussian, it will be considered as foreground
                background = any(background,3);

                % Removal Shadow
                if ~islogical(obj.shadowRemove)
                    background = obj.shadowRemove(imOrig, background, obj.colorInverseTransform(obj.mu));
                end

                % Apply morpho function
                background = obj.morphoFunction(background);

                applyRho = repmat( (~background).*obj.rho,[1,1,size(im,3)] );

                obj.mu = (1-applyRho).*obj.mu + applyRho.*im;
                obj.sigma_square = (1-applyRho).*obj.sigma_square + applyRho.*((im - obj.mu).^2);
                
                segmentedMasks(:,:,count) = background;
                count = count + 1;
            end % for
            
            segmentedMasks = squeeze(segmentedMasks);
        end
    end
end