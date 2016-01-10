function masks = applyMorphoTask2(masks, p) 
    connectivity = 4; % BEST CONNECTIVITY HAS TO BE CHECKED (4 or 8)
    for i=1:size(masks,3)
        % Apply best imfill of Task1
        masks(:,:,i) = imfill(masks(:,:,i), connectivity, 'holes');
        % Now look for best p
        masks(:,:,i) = bwareaopen(masks(:,:,i), p);
    end
end