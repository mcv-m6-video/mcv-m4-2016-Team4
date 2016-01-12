function mask = applyMorphoTask2(mask, p, connectivity) 
    % BEST CONNECTIVITY HAS TO BE CHECKED (4 or 8)
    % Apply best imfill of Task1
    mask = imfill(mask, connectivity, 'holes');
    % Now look for best p
    mask = bwareaopen(mask, p);
end