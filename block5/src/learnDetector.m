if ~exist(['savedResults' filesep 'detectionStep.mat'], 'file')
    learnImages = cell(2,1);
    detector = cell(2,1);
    idSequenceLearn = {1050:1350; 950:1050};
    imagesLearning = cell(2,1);
    inputFolders = cell(2,1);
    homographySeq = cell(2,1);
    
    j = 1;
    for iSeq = [1 3] % Highway y Traffic
        inputFolders{j} = seq.inputFolders{iSeq};
        
        detector{j} = oneGaussianBackgroundAdaptiveModel(seq.alphas(iSeq), seq.rhos(iSeq), colorIm, colorTransform, morphoForegroundFunction);

        % obtenemos las imagenes
        im = imread( [ seq.inputFolders{iSeq} , sprintf('%06d', idSequenceLearn{j}(1)) , fileFormat ] );
        sizeIm = [size(im, 1), size(im, 2)];

        imagesLearning{j} = zeros(size(im,1), size(im,2), size(im,3), length(idSequenceLearn{j}), 'uint8');

        % Calculamos la homografia
        homographySeq{j} = Homography;
        homographySeq{j}.doTFORMVanishPoint(im);
        
        k=1;
        for id=idSequenceLearn{j}
            imName = sprintf('%06d', id);
            fileName = [ seq.inputFolders{iSeq} , imName , fileFormat ];
            
            % Si esta activada aplicamos la tform a cada imagen
            im = imread( fileName );
            
            imagesLearning{j}(:,:,:,k) = im;
            k = k + 1;
        end 
        detector{j}.learn(imagesLearning{j});
        
        % incrementamos el valor
        j = j + 1;
    end
    
    save(['savedResults' filesep 'detectionStep.mat'], 'learnImages', 'detector', 'idSequenceLearn', 'homographySeq', 'inputFolders', 'fileFormat', 'enable_homography', 'sizeIm');
else
    load(['savedResults' filesep 'detectionStep.mat'])
   disp('Detection step results found (savedResults/detectionStep.mat). Skipping detectionStep...'); 
end