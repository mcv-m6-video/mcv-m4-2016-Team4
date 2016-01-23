function mask = detectionMorpho(mask)
    mask = imclose(mask, strel('rectangle', [5, 5]));
    mask = imfill(mask, 'holes');
    mask = bwareaopen(mask, 100, 4);
end