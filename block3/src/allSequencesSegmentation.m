function allSequencesSegmentation(seq, folderBaseResults, fileFormat, colorIm, colorTransform)

    % The execution of this function will create at each sequence directory
    % a folder with the name specified at folderBaseResults with the results 
    % of the model specified in seq.
    % Best model configuration obtaned in B2:
    % Model used: One Gaussian Recursive
    % Color Space: LAB
    % Rho and alpha: customized for each sequence
    saveIm = true;
    for i=1:seq.nSequences
        folderResult = [seq.basePaths{i} folderBaseResults];
        if ~exist(folderResult , 'dir')
            mkdir( folderResult );
        end 
        oneGaussianBackgroundAdaptive( seq.framesInd{i}, seq.inputFolders{i}, fileFormat ,...
                        seq.alphas(i), seq.rhos(i), colorIm , colorTransform, saveIm, folderResult);
    end

end