function [ p , r , f1 ] = getMetrics( tp , fp , fn , tn )
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

    % Precision
    p = tp./(tp + fp);
    p(isnan(p)) = 1; % Avoid 0/0 and 0/0=0

    % Recall
    r = tp./(tp + fn);
    r(isnan(r)) = 1; % Avoid 0/0 and 0/0=0
    
    % F1-score
    f1 = 2.*( p .* r )./(p + r);
    f1(isnan(f1)) = 0; % Avoid 0/0 and 0/0=0
    
end % function

