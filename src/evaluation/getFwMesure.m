function [ fwMesure ] = getFwMesure( groundTruth , foregroundMap , beta , alpha , sigma_sq )
    
    % Parameters
    if ~exist('alpha','var')
        alpha = log(0.5)/5;
    end
    if ~exist('sigma_sq','var')
        sigma_sq = 5;
    end
    if ~exist('beta','var')
        beta = 1;
    end
    
    % LetG1×N denote the column-stack representation of the binary ground-truth, where N is the number of pixels in the image. Let D1×N denote the non-binary map to be evalu- ated against the ground-truth.
    g = groundTruth(:)';
    d = foregroundMap(:)';
    
    % Absolute error of detection (1xN)
    e = abs(g-d);
    
    % Incorporating pixel dependency (NxN)
    A = diag(g==0);
    A = double(sparse(A));
    
    ind = find(g);
    d = dist(ind',ind',size(groundTruth));
    val = 1/sqrt(2*pi*sigma_sq)*exp(-(d^2)/(2*sigma_sq));
    A(ind,ind) = val;  
    
    % Incorporating pixels of varying importance (Nx1)
    B = double(g==1)';
    ind = find(g~=1);
    d = dist(ind', find(g==1)',size(groundTruth));
    deltaI = min(d,[],2);
    B(ind) = 2-exp(alpha*deltaI);
    
    % Weighting error map
    eW = min(e,(e'*A)')*B;
    
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
    fwMesure = (1+beta^2)*(precW*recW)/(beta^2*precW+recW);
    
end % function

function d = dist(i,j,sz)
    [row1,col1] = ind2sub(sz, i);
    [row2,col2] = ind2sub(sz, j);
    d = pdist2([row1,col1] , [row2,col2] );
end
