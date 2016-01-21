function [outputVideo, gtStabilizedVideo] = stabilizeVideo_ROI(video, gtvideo)
    %% Video Stabilization
    % This example shows how to remove the effect of camera motion from a video stream.

    %   Copyright 2006-2014 The MathWorks, Inc.

    %% Introduction
    % In this example we first define the target to track. In this case, it is the
    % back of a car and the license plate. We also establish a dynamic search
    % region, whose position is determined by the last known target location.
    % We then search for the target only within this search region, which
    % reduces the number of computations required to find the target. In each
    % subsequent video frame, we determine how much the target has moved
    % relative to the previous frame. We use this information to remove
    % unwanted translational camera motions and generate a stabilized video. 

    %% Initialization
    % Create a geometric translator System object used to compensate for the
    % camera movement.
    hTranslate = vision.GeometricTranslator( ...
                                  'OutputSize', 'Same as input image', ...
                                  'OffsetSource', 'Input port');

    %%
    % Create a template matcher System object to compute the location of the
    % best match of the target in the video frame. We use this location to find
    % translation between successive video frames.
    hTM = vision.TemplateMatcher('ROIInputPort', true, ...
                                'BestMatchNeighborhoodOutputPort', true);

    %%
    % Here we initialize some variables used in the processing loop.
    pos.template_orig = [9 140]; % [x y] upper left corner
    pos.template_size = [150 150];   % [width height]
    pos.search_border = [50 50];   % max horizontal and vertical displacement
    pos.template_center = floor((pos.template_size-1)/2);
    pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
    sz = [size(video,2), size(video, 1)];
    SearchRegion = pos.template_orig - pos.search_border - 1;
    Offset = [0 0];
    Target = zeros(flip(pos.template_size));
    firstTime = true;

    %% Stream Processing Loop
    % This is the main processing loop which uses the objects we instantiated
    % above to stabilize the input video.
    outputVideo = video.*0;
    gtStabilizedVideo = zeros(size(video,1), size(video,2), 1, size(video,4)-1);
    for i=1:size(video,4)
        input = im2double(rgb2gray(video(:,:,:,i)));

        % Find location of Target in the input video frame
        if firstTime
          Idx = int32(pos.template_center_pos);
          MotionVector = [0 0];
        else
          IdxPrev = Idx;

          ROI = [SearchRegion, pos.template_size+2*pos.search_border];
          Idx = step(hTM, input, Target, ROI);

          MotionVector = double(Idx-IdxPrev);
        end

        [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
            SearchRegion, Offset, pos);

        % Translate video frame to offset the camera motion
        Stabilized = step(hTranslate, input, fliplr(Offset));
        if ~firstTime
            gt = im2double(gtvideo(:,:,:,i-1));
            gtStabilized = step(hTranslate, gt, fliplr(Offset));
            gtStabilizedVideo(:,:,1,i) = uint8(255*gtStabilized);
        end

        outputVideo(:,:,1,i) = uint8(255*Stabilized);
        outputVideo(:,:,2,i) = uint8(255*Stabilized);
        outputVideo(:,:,3,i) = uint8(255*Stabilized);
        
        if firstTime
            firstTime = false;
        end
    end

    
end