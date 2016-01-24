function mask = detectionMorpho(mask)
    mask = imclose(mask, strel('rectangle', [5, 5]));
    mask = imfill(mask, 'holes');
    mask = bwareaopen(mask, 100, 4);
    
    mask = imdilate(mask, strel('disk', 3));
    mask = imfill(mask, 'holes');
    mask = imerode(mask, strel('disk', 3));
end