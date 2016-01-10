function masks = applyMorphoTask4(masks, p, connectivity) 
    for i=1:size(masks,3)
%       El codigo comentado es el mejor hasta ahora, estoy provando otras
%       configuraciones
%         % Remove noise
%         masks(:,:,i) = bwareaopen(masks(:,:,i), p);
%         
%         % Union between adjecent blobs
%         masks(:,:,i) = imclose(masks(:,:,i), strel('disk', 5));
%         
%         % Apply imfill
%         masks(:,:,i) = imfill(masks(:,:,i), connectivity, 'holes');
        
        % Remove noise
        masks(:,:,i) = bwareaopen(masks(:,:,i), p);
        
        % Union between adjecent blobs
        masks(:,:,i) = imclose(masks(:,:,i), strel('disk', 5));
        
        % Apply imfill
        masks(:,:,i) = imfill(masks(:,:,i), connectivity, 'holes');
        
        % Dilate
        masks(:,:,i) = imdilate(masks(:,:,i), strel('disk', 5));
    end
end