function task1(optConnectivity, seq, folderBaseResults)
    %% Task 1
    % Use the Matlab function imfill to fill the black holes inside white regions. Run
    % your experiments by considering both a 4- and a 8-connectivity. Show the results
    % on a table comparing the obtained Precision, Recall and F1-score with the baseline
    % values obtained last week.
    
    for connectivity = optConnectivity
        % Results Folder
        imfillResultsFolder = ['resultsImFill_' num2str(connectivity)];

        precB2 = zeros(seq.nSequences, 1); recB2= zeros(seq.nSequences, 1); f1scoreB2 = zeros(seq.nSequences, 1);
        precT1 = zeros(seq.nSequences, 1); recT1= zeros(seq.nSequences, 1); f1scoreT1 = zeros(seq.nSequences, 1);
        tp = zeros(seq.nSequences, 1); fp = zeros(seq.nSequences, 1); fn = zeros(seq.nSequences, 1); tn = zeros(seq.nSequences, 1);
        for i=1:seq.nSequences
            % The best Block 2 results folder
            folderBestB2Results = [seq.basePaths{i} folderBaseResults];
            if ~exist(folderBestB2Results , 'dir')
                disp('The results folders does not exist!');
                break
            end

            % The folder that we save now the task 1 results
            folderResults = [seq.basePaths{i} imfillResultsFolder '/'];
            if ~exist(folderResults , 'dir')
                mkdir( folderResults );
            end

            % Apply the morphology methods in the task 1
            applyMorphoTask1(folderBestB2Results, folderResults, connectivity);

            % Evaluate the Block 2 results
            [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                segmentationEvaluation(seq.gtFolders{i} , folderResults );
            tp(i) = sum(tpAux); fp(i) = sum(fpAux); fn(i) = sum(fnAux); tn(i) = sum(tnAux);
            [ precAux , recAux , f1Aux ] = getMetrics( tp(i) , fp(i) , fn(i) , tn(i) );
            precB2(i) = precAux; recB2(i) = recAux; f1scoreB2(i) = f1Aux;


            % Evaluate the morphoTask1 results
            [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                segmentationEvaluation(seq.gtFolders{i} , folderResults );
            tp(i) = sum(tpAux); fp(i) = sum(fpAux); fn(i) = sum(fnAux); tn(i) = sum(tnAux);
            [ precAux , recAux , f1Aux ] = getMetrics( tp(i) , fp(i) , fn(i) , tn(i) );
            precT1(i) = precAux; recT1(i) = recAux; f1scoreT1(i) = f1Aux;
        end  
    end
    
    % Comparation results
end
