if ~exist(['savedResults' filesep 'detectionStep.mat'], 'file')
    sequencesToAnalyze = [1 3 4 5 6 7]; % Highway y Traffic and own video
    learnImages = cell(length(sequencesToAnalyze),1);
    detector = cell(length(sequencesToAnalyze),1);
    idSequenceLearn = {1050:1350; 950:1050};
    imagesLearning = cell(length(sequencesToAnalyze),1);
    inputFolders = cell(length(sequencesToAnalyze),1);
    homographySeq = cell(length(sequencesToAnalyze),1);
    
    velocityEstimator = [];
    
    j = 1;
    for iSeq = sequencesToAnalyze
        inputFolders{j} = seq.inputFolders{iSeq};
        
        detector{j} = oneGaussianBackgroundAdaptiveModel(seq.alphas(iSeq), seq.rhos(iSeq), colorIm, colorTransform, morphoForegroundFunction);

        % obtenemos las imagenes
        im = imread( [ seq.inputFolders{iSeq} , sprintf('%06d', seq.framesInd{iSeq}(j)) , fileFormat ] );
        sizeIm = [size(im, 1), size(im, 2)];

        imagesLearning{j} = zeros(size(im,1), size(im,2), size(im,3), length(seq.framesInd{iSeq}), 'uint8');

        % Calculamos el factor alpha
        figure(1),imshow(im), title('Select a distance:');
        [l1, l2] = ginput(2);
        lineLen = pdist2(l1',l2');
        realLen = input('Which is the real distance?\n');

        velocityEstimator(end+1) = realLen/lineLen;
        
        % Calculamos la homografia
        homographySeq{j} = Homography;
        homographySeq{j}.doTFORMVanishPoint(im);
        
        k=1;
        for id=seq.framesInd{iSeq}
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
    
    save(['savedResults' filesep 'detectionStep.mat'], 'learnImages', 'detector', 'idSequenceLearn', 'homographySeq', 'inputFolders', 'fileFormat', 'enable_homography', 'sizeIm', 'velocityEstimator');
else
    load(['savedResults' filesep 'detectionStep.mat'])
   disp('Detection step results found (savedResults/detectionStep.mat). Skipping detectionStep...'); 
end