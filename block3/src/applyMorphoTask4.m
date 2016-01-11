function masks = applyMorphoTask4(masks, p, connectivity, close) 
    for i=1:size(masks,3)
%       El codigo comentado es el mejor hasta ahora, estoy provando otras
%       configuraciones

        % Remove noise
        masks(:,:,i) = bwareaopen(masks(:,:,i), p);
        
        % Union between adjecent blobs
        masks(:,:,i) = imclose(masks(:,:,i), strel('disk', close));
        
        % Apply imfill
        masks(:,:,i) = imfill(masks(:,:,i), connectivity, 'holes');
    end
end