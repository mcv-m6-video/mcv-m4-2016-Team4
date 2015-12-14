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
    den = tp + fp;
    if den == 0
        p = 0;
    else
        p = tp./den;
    end % if

    % Recall
    den = tp + fn;
    if den == 0
        r = 0;
    else
        r = tp./den;
    end % if
    
    % F1-score
    den = p + r;
    if den == 0
        f1 = 0;
    else
        f1 = 2.*( p .* r )./den;
    end % if
    
end % function

