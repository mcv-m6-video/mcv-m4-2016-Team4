function task2(pixels , seq , folderBaseResults)
    %% Task 2
    % Use the Matlab function bwareaopen to filter out those regions which are too
    % small to be considered a car. Plot a graph relating the allowed minimum size with
    % the obtained F1 score. The graph must plot four cases: (a) baseline results with no
    % morphological filtering, (b) area filtering only, (c) area filtering + hole filling with
    % connectivity 4 and (d) area filtering + hole filling with connectivity 8. Analyse the
    % results of the graph.
    
    precT1 = zeros(seq.nSequences, 1); recT1= zeros(seq.nSequences, 1); f1scoreT1 = zeros(seq.nSequences, 1);
    precT2 = zeros(seq.nSequences, length(pixels)); recT2= zeros(seq.nSequences, length(pixels)); f1scoreT2 = zeros(seq.nSequences, length(pixels));

    % Apply the algorithm to each sequence
    for i=1:seq.nSequences
        % The best Block 2 results folder
        folderBestT1Results = [seq.basePaths{i} folderBaseResults];
        if ~exist(folderBestT1Results , 'dir')
            disp('The results folders does not exist!');
            break
        end
        
        % Evaluate the Block 2 results
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation(seq.gtFolders{i} , folderBestT1Results );
        tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
        [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
        precT1(i) = precAux; recT1(i) = recAux; f1scoreT1(i) = f1Aux;

        % Results Folder
        areaopenResultsFolder = 'resultsAreaOpen';

        % The folder that we save now the task 1 results
        folderResults = [seq.basePaths{i} areaopenResultsFolder '/'];
        if ~exist(folderResults , 'dir')
            mkdir( folderResults );
        end
        
        % Apply the algorithm to all the connectivity options asked in
        % optConnectivity.
        j = 1;
        for p = pixels
            p
            % Apply the morphology methods in the task 1
            applyMorphoTask2(folderBestT1Results, folderResults, p);

            % Evaluate the morphoTask1 results
            [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
                segmentationEvaluation(seq.gtFolders{i} , folderResults );
            tp = sum(tpAux); fp = sum(fpAux); fn = sum(fnAux); tn = sum(tnAux);
            [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
            precT2(i,j) = precAux; recT2(i,j) = recAux; f1scoreT2(i,j) = f1Aux;
            
            j = j + 1;
        end
    end
    
    % Comparation results
end
