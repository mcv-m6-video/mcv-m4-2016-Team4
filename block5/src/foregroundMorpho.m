function mask = foregroundMorpho(mask)
    % Remove noise
    mask = bwareaopen(mask, 30);
    
    % Union between adjecent blobs
    mask = imclose(mask, strel('disk', 5));
    
    % Apply imfill
    mask = imfill(mask, 4, 'holes');
end