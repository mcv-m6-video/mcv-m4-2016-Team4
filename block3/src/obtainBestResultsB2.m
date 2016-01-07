function obtainBestResultsB2
    % The execution of this function will create at each sequence directory
    % a folder named 'bestResultsB2' with the results that gave the best
    % F1Score in B2. 
    % Model used: One Gaussian Recursive
    % Color Space: LAB
    % Rho and alpha: customized for each sequence
    
    % Initialize global parameters
    setup;
    
    for i=1:seq.nSequences
        folderResult = [seq.basePaths{i} folderBaseResults];
        if ~exist(folderResult , 'dir')
            mkdir( folderResult );
        end 
        oneGaussianBackgroundAdaptive( seq.framesInd{i}, seq.inputFolders{i}, fileFormat ,...
                        folderResult, seq.alphas(i), seq.rhos(i), colorIm , colorTransform);
    end
    
    
end