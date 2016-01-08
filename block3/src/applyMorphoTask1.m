function applyMorphoTask1(folderIn, folderResults, connectivity) 
    listImagesResult = dir([folderIn '*.png']);
    for j=1:length(listImagesResult)
        nameImage = listImagesResult(j).name;
        image = imread([folderIn nameImage])==1;
        
        % Apply imfill
        imageResult = imfill(image, connectivity, 'holes');
        imwrite(imageResult, [folderResults nameImage]);
    end
end