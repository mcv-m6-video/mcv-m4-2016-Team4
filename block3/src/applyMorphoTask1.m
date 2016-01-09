function masks = applyMorphoTask1(masks, connectivity) 
    for i=1:size(masks,3)
        % Apply imfill
        masks(:,:,i) = imfill(masks(:,:,i), connectivity, 'holes');
    end
end