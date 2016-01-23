if ~exist(['savedResults' filesep 'detectionStep.mat'], 'file')
    learnImages = cell(2,1);
    detector = cell(2,1);
    idSequenceLearn = {1050:1350; 950:1050};
    imagesLearning = cell(2,1);
    tform = cell(2,1);
    
    j = 1;
    for iSeq = [1 3] % Highway y Traffic
        detector{j} = oneGaussianBackgroundAdaptiveModel(seq.alphas(iSeq), seq.rhos(iSeq), colorIm, colorTransform, morphoFunction);

        % obtenemos las imagenes
        im = imread( [ seq.inputFolders{iSeq} , sprintf('%06d', length(idSequenceLearn{j})) , fileFormat ] );
        
        % Si esta habilitada la homografia, la aplicamos y obtenemos la
        % matriz de transformacion
        if enable_homography
            [im, tform{j}] = getHomographyTransform(im);
        end
        
        imagesLearning{j} = zeros(size(im,1), size(im,2), size(im,3), numel(listIds));

        k=1;
        for id=listIds
            imName = sprintf('%06d', id);
            fileName = [ seq.inputFolders{iSeq} , imName , fileFormat ];
            
            % Si esta activada aplicamos la tform a cada imagen
            if enable_homography
                im = imwarp(imread( fileName ), tform{j});
            end
            
            imagesLearning{j}(:,:,:,k) = im;
            k = k + 1;
        end 
        detector{j}.learn(imagesLearning{j});
        
        % incrementamos el valor
        j = j + 1;
    end
    
    save(['savedResults' filesep 'detectionStep.mat'], 'learnImages', 'detector', 'idSequenceLearn', 'tform');
else
    load(['savedResults' filesep 'detectionStep.mat'])
   disp('Detection step results found (savedResults/detectionStep.mat). Skipping detectionStep...'); 
end