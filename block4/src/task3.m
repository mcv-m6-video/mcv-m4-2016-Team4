function task3(seqPath, seqFramesInd, gtPath, opticalFlowFunction, fileFormat, folderFigures)
    % Reads the sequence (frames located at 'seqPath' and indicated by 
    % seqFramesInd), stabilize it using 'opticalFlowFunction', and finally, 
    % evaluate theresults with the  original jittering sequence (PR curve, 
    % AUC and best F1-Score)
    % - opticalFlowFunction: function where the first parameter corresponds
    %                 to video sequence and the others are irrelevant. Given 
    %                 a video sequence, it returns its optical flow.
    
    if ~exist(['savedResults' filesep 'dataTask3.mat'], 'file')
        %% Read sequence
        colorIm = true;
        video = readVideo(seqPath, seqFramesInd, fileFormat, colorIm);

        %% Stabilize
        % Extract the optical flow from the video
        blockSize = [17 17];
        areaSearch = [7, 7];

        flow = opticalFlowFunction(uint8(video), '', zeros(size(video,4),1));
        % Now we can call the stabilization video function
        videoStab = stabilizeVideo(video, flow);

        %% Evaluation: compare the stabilized video with the original
        % In order to evaluate the stabilized video, it is necessary to
        % stabilize the ground truth, too.

        % Read GT.
        videoGT = readVideo(gtPath, seqFramesInd, '.png', false);
        
        % Apply the same stabilization applied at the original video
        videoGTStab = stabilizeVideo(videoGT, flow);
        
        % Get precision and recall from both sequences
        [prec, rec, f1] = applyBestSegmentation(video, videoGT);
        [precStab, recStab, f1Stab] = applyBestSegmentation(videoStab, videoGTStab);
        
    else
       disp('Task 3 results found (savedResults/dataTask3.mat). Skipping computation of results...');  
    end
   
    %% Plot evaluation results
    % Plot both PR curves and AUC
    taskId = '3';
    legendStr = {'No stabilization', 'Stabilization'};
    [aucs] = calculateAUCs([prec precStab], [rec recStab], folderFigures, legendStr, taskId);
    fprintf('AUC (no stabilization): %.4f\nAUC (stabilization): %.4f\n', aucs(1), aucs(2));
    
    % F1-Score for the best threshold
    fprintf('Best F1-Score (no stabilization): %.2f%%\nBest F1-Score (stabilization): %.2f%%\n', max(f1)*100, max(f1Stab)*100);

end