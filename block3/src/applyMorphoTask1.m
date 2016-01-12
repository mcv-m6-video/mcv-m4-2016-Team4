function mask = applyMorphoTask1(mask, connectivity) 
    % Apply imfill
    mask = imfill(mask, connectivity, 'holes');
end