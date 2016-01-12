function mask = applyMorphoTask4(mask, p, connectivity, close) 
%       El codigo comentado es el mejor hasta ahora, estoy provando otras
%       configuraciones

    % Remove noise
    mask = bwareaopen(mask, p);
    
    % Union between adjecent blobs
    mask = imclose(mask, strel('disk', close));
    
    % Apply imfill
    mask = imfill(mask, connectivity, 'holes');
end