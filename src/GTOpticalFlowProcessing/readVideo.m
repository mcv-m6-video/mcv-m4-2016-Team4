function video = readVideo(framesPath, framesInd, imageFormat, enableColor)
% Given a path that contains images, it reads the images specified by
% framesInd.
% Output: - video: NxMxOxK matrix where NxMxO is the size of the frames and 
%                  K is the total amount of frames
    if ~exist('enableColor','var')
        enableColor = false;
    end
    % First iteration is done before so we can initialize the video
    % sequence matrix
    frameName = sprintf('%06d', framesInd(1));
    framePath = [ framesPath , frameName , imageFormat ];
    frame = imread(framePath);
    if size(frame,3) == 3 && not(enableColor)
       frame = rgb2gray(frame) ;
    end
    
    % video is an NxMxOxK matrix, where NxMxO is the size of the frames and
    % K is the total number of frames.
    video = zeros(size(frame,1), size(frame,2), size(frame,3), length(framesInd), 'like', frame);
    video(:,:,:,1) = frame;
    
    % For every indicated frame in the sequence
    for i=2:length(framesInd)
        % Read the frame of the sequence
        frameName = sprintf('%06d', framesInd(i));
        framePath = [ framesPath , frameName , imageFormat ];
        frame = imread(framePath);
        if size(frame,3) == 3 && not(enableColor)
            frame = rgb2gray(frame) ;
        end
        % Accumulate it on the video
        video(:,:,:,i) = frame;
    end
end