function applyMorphoTask2(folderIn, folderResults, p) 
    listImagesResult = dir([folderIn '*.png']);
    for j=1:length(listImagesResult)
        nameImage = listImagesResult(j).name;
        image = imread([folderIn nameImage])==1;
        
        % Apply imfill
        imageResult = bwareaopen(image, p);
        imwrite(imageResult, [folderResults nameImage]);
    end
end