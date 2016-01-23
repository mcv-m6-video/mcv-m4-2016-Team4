function [imOut, t] = getHomographyTransform(im)
    figure(1),imshow(im), title('Select the left line:');
    [x, y] = ginput(2);
    line1 = [x, y];
    figure(1),imshow(im), title('Select the right line:');
    [x, y] = ginput(2);
    line2 = [x, y]; 
    [imOut, t] = imHomography(im, line1, line2);
    imshow(imOut), title('This is the result, press space to continue...'), pause;
end