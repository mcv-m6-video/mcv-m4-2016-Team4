function [S, CC] = getCentroids(mask)
    CC = bwconncomp(mask);
    S = regionprops(CC,'Centroid');
end