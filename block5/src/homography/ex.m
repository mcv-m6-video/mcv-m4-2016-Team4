load('../videos.mat');

figure(1),imshow(video(:,:,:,1)), title('Select the left line:');
[x, y] = ginput(2);
line1 = [x, y];
figure(1),imshow(video(:,:,:,1)), title('Select the right line:');
[x, y] = ginput(2);
line2 = [x, y]; 
[imOut, t] = imHomography(video(:,:,:,1), line1, line2);

for i=1:size(video,4)
    figure(1), imshow(imwarp(video(:,:,:,i), t)), pause;
end