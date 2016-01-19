function outputVideo = stabilizeVideo(video, optFlow)
% Stabilizes video with opticalFlowFunc.
% Input: - video: NxMxK matrix where NxM is the size of the frames and K is
%                 the total amount of frames.
%        - optFlow: optical flow estimation for every pair of frames.
    
    outputVideo = zeros(size(video),'like',video);
    error('stabilizeVideo not implemented yet.')

end