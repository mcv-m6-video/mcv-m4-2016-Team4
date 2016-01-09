function task1(optConnectivity, seq, fileFormat, colorIm, colorTransform, alphaValues)
    %% Task 1
    % Use the Matlab function imfill to fill the black holes inside white regions. Run
    % your experiments by considering both a 4- and a 8-connectivity. Show the results
    % on a table comparing the obtained Precision, Recall and F1-score with the baseline
    % values obtained last week.
    
    % Turn opt connectivity to a row.
    optConnectivity = optConnectivity(:)';
        
    precB2 = zeros(seq.nSequences, length(alphaValues)); recB2= zeros(seq.nSequences, length(alphaValues)); f1scoreB2 = zeros(seq.nSequences, length(alphaValues));
    precT1 = zeros(seq.nSequences, length(alphaValues), length(optConnectivity)); recT1= zeros(seq.nSequences, length(alphaValues), length(optConnectivity)); f1scoreT1 = zeros(seq.nSequences, length(alphaValues), length(optConnectivity));

    % Apply the algorithm to each sequence
    for i=1:seq.nSequences
        k=1;
        for alpha=alphaValues(:)'
            % The Block 2 results using this alpha
            folderB2Results = [seq.basePaths{i} 'resultsAlphaB2/'];
            if ~exist(folderB2Results , 'dir')
                mkdir(folderB2Results);
            end
            oneGaussianBackgroundAdaptive( seq.framesInd{i}, seq.inputFolders{i}, fileFormat ,...
                        folderB2Results, alpha, seq.rhos(i), colorIm , colorTransform);           

            % Evaluate the Block 2 results
            [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                segmentationEvaluation(seq.gtFolders{i} , folderB2Results );
            tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
            [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
            precB2(i, k) = precAux; recB2(i, k) = recAux; f1scoreB2(i, k) = f1Aux;

            % Apply the algorithm to all the connectivity options asked in
            % optConnectivity.
            j = 1;
            for connectivity = optConnectivity
                % Results Folder
                imfillResultsFolder = ['resultsImFill_' num2str(connectivity)];

                % The folder that we save now the task 1 results
                folderResults = [seq.basePaths{i} imfillResultsFolder '/'];
                if ~exist(folderResults , 'dir')
                    mkdir( folderResults );
                end

                % Apply the morphology methods in the task 1
                applyMorphoTask1(folderB2Results, folderResults, connectivity);

                % Evaluate the morphoTask1 results
                [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                    segmentationEvaluation(seq.gtFolders{i} , folderResults );
                tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
                [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
                precT1(i, k, j) = precAux; recT1(i, k, j) = recAux; f1scoreT1(i, k, j) = f1Aux;

                j = j + 1;
            end
            k = k + 1;
        end
    end

    % Comparation results
    save('dataTask1', 'precB2', 'recB2', 'f1scoreB2', 'precT1', 'recT1', 'f1scoreT1', 'alphaValues', 'optConnectivity')
    
end
