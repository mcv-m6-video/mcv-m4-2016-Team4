function [outputVideo, outputGt] = stabilizeVideo_pm(video, gt)
    
    %% Step 6. Run on the Full Video
    % Now we apply the above steps to smooth a video sequence. For readability,
    % the above procedure of estimating the transform between two images has
    % been placed in the MATLAB(R) function
    % <matlab:edit(fullfile(matlabroot,'toolbox','vision','visiondemos','cvexEstStabilizationTform.m')) |cvexEstStabilizationTform|>.
    % The function
    % <matlab:edit(fullfile(matlabroot,'toolbox','vision','visiondemos','cvexTformToSRT.m')) |cvexTformToSRT|>
    % also converts a general affine transform into a
    % scale-rotation-translation transform.
    %
    % At each step we calculate the transform $H$ between the present frames.
    % We fit this as an s-R-t transform, $H_{sRt}$. Then we combine this the
    % cumulative transform, $H_{cumulative}$, which describes all camera motion
    % since the first frame. The last two frames of the smoothed video are
    % shown in a Video Player as a red-cyan composite.
    %
    % With this code, you can also take out the early exit condition to make
    % the loop process the entire video.

    % Reset the video source to the beginning of the file.

    % Process all frames in the video
    movMean = rgb2gray(video(:,:,:,1));
    imgB = movMean;
    imgBp = imgB;
    correctedMean = imgBp;
    
    outputVideo = imgB;
    outputGt = gt(:,:,:,1);

    ii = 2;
    Hcumulative = eye(3);
    while ii <= size(video,4)
        % Read in new frame
        imgA = imgB; % z^-1
        imgAp = imgBp; % z^-1
        imgB = rgb2gray(video(:,:,:,ii));
        movMean = movMean + imgB;

        % Estimate transform from frame A to frame B, and fit as an s-R-t
        H = cvexEstStabilizationTform_pm(imgA,imgB,0.00001, 0.00001);
            
        HsRt = cvexTformToSRT(H);
        Hcumulative = HsRt * Hcumulative;
        imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
        
        outputVideo(:,:,ii) = imgBp;
        outputGt(:,:,ii) = imwarp(gt(:,:,:,ii),affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

        % Display as color composite with last corrected frame
        correctedMean = correctedMean + imgBp;

        ii = ii+1;
    end
    correctedMean = correctedMean/(ii-2);
    movMean = movMean/(ii-2);


    %%
    % During computation, we computed the mean of the raw video frames and of
    % the corrected frames. These mean values are shown side-by-side below. The
    % left image shows the mean of the raw input frames, proving that there was
    % a great deal of distortion in the original video. The mean of the
    % corrected frames on the right, however, shows the image core with almost
    % no distortion. While foreground details have been blurred (as a necessary
    % result of the car's forward motion), this shows the efficacy of the
    % stabilization algorithm.

    %% References
    % [1] Tordoff, B; Murray, DW. "Guided sampling and consensus for motion
    % estimation." European Conference n Computer Vision, 2002.
    %
    % [2] Lee, KY; Chuang, YY; Chen, BY; Ouhyoung, M. "Video Stabilization
    % using Robust Feature Trajectories." National Taiwan University, 2009.
    % 
    % [3] Litvin, A; Konrad, J; Karl, WC. "Probabilistic video stabilization
    % using Kalman filtering and mosaicking." IS&T/SPIE Symposium on Electronic
    % Imaging, Image and Video Communications and Proc., 2003.
    %
    % [4] Matsushita, Y; Ofek, E; Tang, X; Shum, HY. "Full-frame Video
    % Stabilization." Microsoft(R) Research Asia. CVPR 2005.
end