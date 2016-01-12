function [ p , r , f1 ] = getFwMesure( groundTruth , foregroundMap )
%GETMETRICS Compute the metrics depending on the input arguments
%   Recieve the metrics:
%       * True Positives (TP)
%       * False Positives (FP)
%       * True Negatives (FN)
%       * False Negatives (TN)
%   The output are:
%       * Precision (P)
%       * Recall (R)
%       * F1-score (F1)
    
    % LetG1×N denotethecolumn-stackrepresentationofthe binary ground-truth, where N is the number of pixels in the image. Let D1×N denote the non-binary map to be evalu- ated against the ground-truth.
    g = groundTruth(:);
    d = foregroundMap(:);
    
    % Absolute error of detection (1xN)
    e = abs(g-d);
    
    % Incorporating pixel dependency
    A = diag(g==0);
    sigma_sq = 5;
    
    % Incorporating pixels of varying importance 
    B = G==1;
    alpha = log(0.5)/5;
    B(B==0) = 2;
    
    % Weighting error map
    eW = min(e,e*A)*B;
    
    % Quantities redefined
    tpW = (1-eW)*g;
    tnW = (1-eW)*(1-g);
    fpW = eW*(1-g);
    fnW = eW*g;
    
    % weighted Precision
    precW = tpW/(tpW + fpW);
    precW(isnan(precW)) = 1;

    % weighted Recall
    recW = tpW/(tpW + fnW);
    recW(isnan(recW)) = 1;
    
    % weighted Fb-score
    f1 = (1+beta^2)*(precW*recW)/(beta^2*precW+recW);
    
end % function

function d = dist(i,j,sz)
    [row1,col1] = ind2sub(sz, i);
    [row2,col2] = ind2sub(sz, j);
    d = pdist2([row1,col1] , [row2,col2] );
end
