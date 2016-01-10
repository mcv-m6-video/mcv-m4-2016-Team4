function masks = applyMorphoTask4(masks, p, connectivity) 
    for i=1:size(masks,3)
        masks(:,:,i) = imclose(masks(:,:,i), strel('disk', 5));
        masks(:,:,i) = imopen(masks(:,:,i), strel('disk', 1));
        % Apply imfill
        masks(:,:,i) = imfill(masks(:,:,i), connectivity, 'holes');
        
        masks(:,:,i) = bwareaopen(masks(:,:,i), p);
    end
end