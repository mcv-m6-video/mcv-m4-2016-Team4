function task3(seqPath, seqFramesInd, gtPath, opticalFlowFunction, fileFormat)
    % Reads the sequence (frames located at 'seqPath' and indicated by 
    % seqFramesInd), stabilize it using 'opticalFlowFunction', and finally, 
    % evaluate theresults with the  original jittering sequence (PR curve, 
    % AUC and best F1-Score)
    % - opticalFlowFunction: function where the first parameter corresponds
    %                 to video sequence and the others are irrelevant. Given a
    %                 video sequence, it returns its optical flow.
    
    %% Read sequence
    video = readVideo(seqPath, seqFramesInd, fileFormat);
    
    %% Stabilize
    % Extract the optical flow from the video
    blockSize = [17 17];
    areaSearch = [7, 7];
    


    flow = opticalFlowFunction(uint8(video), '', zeros(size(video,3),1));
    % Now we can call the stabilization video function
    videoStab = stabilizeVideo(video, flow);
    
    %% Evaluation: compare the stabilized video with the original
    % In order to evaluate the stabilized video, it is necessary to
    % stabilize the ground truth, too.
    
    % Read GT.
    videoGT = readVideo(gtPath, seqFramesInd, '.png');
    
    % Apply the same stabilization applied at the original video
    videoGTStab = stabilizeVideo(videoGT, flow);
    
    % Plot both PR curves and AUC
    
    % F1-Score for the best threshold
    

end