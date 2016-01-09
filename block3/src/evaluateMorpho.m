function evaluateMorpho(seq, fileFormat, alphaValues, morphThresholds, morphFunction, colorIm, colorTransform)
    %% evaluateMorpho
    % Iterate through all sequences and apply a morphological operation
    % specified by morphFunction (which, at the same time, will iterate in
    % the values specified in morphThreshold). The precision recall curve
    % and its AUC will be calculated.
    % Input:
    %   - seq: struct containing all the sequence info
    %   - folderBaseResults: string indicating the folder were the results
    %                        will be saved.
    %   - morphFunction: function that will apply a morphological operation
    %                    to each resulting mask. Parameters of morphFunction
    %                    have to be (masks, morphThreshold(i))                    
    %   - morphThresholds: thresholds used to iterate through morphFunction.
    %   
    
    if ~exist('morphFunction','var')
        morphFunction = @(x)x;
    end
    
    saveIm = false; % We don't want to store any masks for this evaluation
    
    precB2 = zeros(seq.nSequences, length(alphaValues)); 
    recB2= zeros(seq.nSequences, length(alphaValues)); 
    f1scoreB2 = zeros(seq.nSequences, length(alphaValues));
    
    precT1 = zeros(seq.nSequences, length(alphaValues), length(morphThresholds)); 
    recT1= zeros(seq.nSequences, length(alphaValues), length(morphThresholds)); 
    f1scoreT1 = zeros(seq.nSequences, length(alphaValues), length(morphThresholds));

   % Apply the algorithm to each sequence
    for i=1:seq.nSequences
        k=1;
        for alpha=alphaValues(:)'
            % Calculate Block 2 results using this alpha
            [masks, maskNames] = oneGaussianBackgroundAdaptive( seq.framesInd{i}, seq.inputFolders{i},...
                    fileFormat, alpha, seq.rhos(i), colorIm , colorTransform, saveIm);           

            % Evaluate the Block 2 results
            [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                segmentationEvaluation(seq.gtFolders{i}, masks, maskNames);
            tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
            [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
            precB2(i, k) = precAux; recB2(i, k) = recAux; f1scoreB2(i, k) = f1Aux;

            % Apply the algorithm to all the connectivity options asked in
            % optConnectivity.
            j = 1;
            for morphTh = morphThresholds
                % Apply the morphology methods in the task 1
                masksMorph = morphFunction(masks, morphTh);

                % Evaluate the morphoTask1 results
                [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                    segmentationEvaluation(seq.gtFolders{i}, masksMorph, maskNames);
                tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
                [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
                precT1(i, k, j) = precAux; recT1(i, k, j) = recAux; f1scoreT1(i, k, j) = f1Aux;

                j = j + 1;
            end
            k = k + 1;
        end
    end

    % Comparation results
    if ~exist('savedResults','dir')
        mkdir('savedResults');
    end
    save(['savedResults' filesep 'dataTask1'], 'precB2', 'recB2', 'f1scoreB2', 'precT1', 'recT1', 'f1scoreT1', 'alphaValues', 'morphThresholds');
    
end
