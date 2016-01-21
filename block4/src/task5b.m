function task5b(seqPath, seqFramesInd, gtPath, fileFormat, folderFigures)
    % Reads the sequence (frames located at 'seqPath' and indicated by 
    % seqFramesInd), stabilize it using 'opticalFlowFunction', and finally, 
    % evaluate theresults with the  original jittering sequence (PR curve, 
    % AUC and best F1-Score)
    % - opticalFlowFunction: function where the first parameter corresponds
    %                 to video sequence and the others are irrelevant. Given 
    %                 a video sequence, it returns its optical flow.
    
    if ~exist(['savedResults' filesep 'dataTask5b.mat'], 'file')
        %% Read sequence
        colorIm = true;
        video = readVideo(seqPath, seqFramesInd, fileFormat, colorIm);

        % Read GT.
        videoGT = readVideo(gtPath, seqFramesInd, '.png', false);

        %% Stabilize
        % Now we can call the stabilization video function
        [videoStab, videoGTStab] = stabilizeVideo_ROI(video, videoGT);

        %% Evaluation: compare the stabilized video with the original
        % In order to evaluate the stabilized video, it is necessary to
        % stabilize the ground truth, too.
        
        newVideo = zeros(size(video,1), size(video,2), 1, size(video,4), 'like', rgb2gray(video(:,:,:,1)));
        for i = 1:size(video,4)
            newVideo(:,:,:,i) = rgb2gray(video(:,:,:,i));
        end
        % Get precision and recall from both sequences
        [prec, rec, f1] = applyBestSegmentation(newVideo, videoGT);
        [precStab, recStab, f1Stab] = applyBestSegmentation(videoStab, videoGTStab);
        
        % Save results
        if ~exist('savedResults','dir')
            mkdir('savedResults');
        end
        save('savedResults/dataTask5b.mat', 'prec', 'rec', 'f1', 'precStab', 'recStab', 'f1Stab');
        
    else
       load('savedResults/dataTask5b.mat');
       disp('Task 5b results found (savedResults/dataTask5a.mat). Skipping computation of results...');  
    end
   
    %% Plot evaluation results
    % Plot both PR curves and AUC
    taskId = '5b';
    legendStr = {'No stabilization', 'Stabilization'};
    [aucs] = calculateAUCs([prec precStab], [rec recStab], folderFigures, legendStr, taskId);
    fprintf('AUC (no stabilization): %.4f\nAUC (stabilization): %.4f\n', aucs(1), aucs(2));
    
    % F1-Score for the best threshold
    fprintf('Best F1-Score (no stabilization): %.2f%%\nBest F1-Score (stabilization): %.2f%%\n', max(f1)*100, max(f1Stab)*100);

end