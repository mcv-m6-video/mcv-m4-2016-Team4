function [precision, recall, f1score] = applyBestSegmentation(video, videoGT)
    % Given one sequence 'video' to be segmented and its GT 'videoGT',
    % compute the precision, recall and F1-Score. The segmentation applied
    % has hard-coded parameters because it's supposed to be the best one
    % obtained from a previous evaluation.
    
    % Initialization of some parameters
    minAlpha=0; stepAlpha=1; maxAlpha=20;
    alphaValues = minAlpha:stepAlpha:maxAlpha;
    precision = zeros(length(alphaValues), 1); 
    recall = zeros(length(alphaValues), 1); 
    f1score = zeros(length(alphaValues),1 );
    saveIm = false;
    colorIm = false;
    shadowRemove = true;
    if size(video,3) == 3
        colorIm = true;
    end
    % Reshape videoGT (NxMxOxK) to NxMxK, because GT images are greyscaled.
    masksGT = reshape(videoGT, size(videoGT,1), size(videoGT,2), size(videoGT,4));
    
    % Cut masksGT in a half, since it contains the frames used for evaluation
    masksGT = masksGT(:,:,floor(size(masksGT,3)/2)+1:size(masksGT,3));
    
    % Set best parameters from the previous Block 3 (shadow removal +
    % morpho + one gaussian adaptative + colorspave luv)
    bestPixels = 300; bestConnectivity = 4; bestClose = 3; bestRho = 0.2;
    colorTransformCell = @rgb2lab;
    morphFunc = @(mask) applyBestMorpho(mask, bestPixels, bestConnectivity, bestClose);
    
    i = 1;
    for alpha=alphaValues
        % Segment foreground and background
        masks = oneGaussianBackgroundAdaptiveIm( video, alpha, bestRho, colorIm , colorTransformCell, morphFunc, shadowRemove, saveIm);
        
        % Evaluate results
        [ tp , fp , fn , tn, ~ , ~ ] = segmentationEvaluation( masksGT, masks );
        tp = sum(tp); fp = sum(fp); fn = sum(fn); tn = sum(tn);
        
        % Extract precision, recall and F1-Score
        [ precAux , recAux , f1Aux ] = getMetrics( tp , fp , fn , tn );
        precision(i) = precAux; recall(i) = recAux; f1score(i) = f1Aux;
        
        i = i + 1;
    end

end

function mask = applyBestMorpho(mask, pixelsAreaOpen, connectivity, pixelsClose)
    % Remove noise
    mask = bwareaopen(mask, pixelsAreaOpen);
    
    % Union between adjecent blobs
    mask = imclose(mask, strel('disk', pixelsClose));
    
    % Apply imfill
    mask = imfill(mask, connectivity, 'holes');
end