function task1(optConnectivity, seq, folderBaseResults)
    %% Task 1
    % Use the Matlab function imfill to fill the black holes inside white regions. Run
    % your experiments by considering both a 4- and a 8-connectivity. Show the results
    % on a table comparing the obtained Precision, Recall and F1-score with the baseline
    % values obtained last week.
    
    % Turn opt connectivity to a row.
    optConnectivity = optConnectivity(:)';
        
    precB2 = zeros(seq.nSequences, 1); recB2= zeros(seq.nSequences, 1); f1scoreB2 = zeros(seq.nSequences, 1);
    precT1 = zeros(seq.nSequences, length(optConnectivity)); recT1= zeros(seq.nSequences, length(optConnectivity)); f1scoreT1 = zeros(seq.nSequences, length(optConnectivity));

    % Apply the algorithm to each sequence
    for i=1:seq.nSequences
        % The best Block 2 results folder
        folderBestB2Results = [seq.basePaths{i} folderBaseResults];
        if ~exist(folderBestB2Results , 'dir')
            disp('The results folders does not exist!');
            break
        end
        
        % Evaluate the Block 2 results
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation(seq.gtFolders{i} , folderBestB2Results );
        tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
        [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
        precB2(i) = precAux; recB2(i) = recAux; f1scoreB2(i) = f1Aux;

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
            applyMorphoTask1(folderBestB2Results, folderResults, connectivity);

            % Evaluate the morphoTask1 results
            [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                segmentationEvaluation(seq.gtFolders{i} , folderResults );
            tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
            [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
            precT1(i, j) = precAux; recT1(i, j) = recAux; f1scoreT1(i, j) = f1Aux;
            
            j = j + 1;
        end  
    end
    
    % Comparation results
    aa=1;
end
