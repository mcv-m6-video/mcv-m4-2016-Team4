function task4
    addpath('flow_code');
    addpath(genpath('flow_code/utils'));
    
    if ~exist( 'pepnThresh' , 'var' )
        pepnThresh = 3;
    end % if
    
    % Reads the sequence (frames located at 'seqPath' and indicated by 
    % seqFramesInd), stabilize it using 'opticalFlowFunction', and finally, 
    % evaluate theresults with the  original jittering sequence (PR curve, 
    % AUC and best F1-Score)
    % - opticalFlowFunction: function where the first parameter corresponds
    %                 to video sequence and the others are irrelevant. Given a
    %                 video sequence, it returns its optical flow.
    
    %% Read sequence
    filePath = '../../datasets/middlebury/';
    imgFilePath     = [filePath 'other-data-gray/'];        
    flowFilePath    = [filePath 'other-gt-flow/'];        

    
    subPath = {'Venus', 'Dimetrodon',   'Hydrangea',    'RubberWhale',...
                'Grove2', 'Grove3', 'Urban2', 'Urban3', ...
                'Walking', 'Beanbags',     'DogDance',     'MiniCooper'};
    
    for iSeq=2:length(subPath),
        disp(['Sequence : ' subPath{iSeq}]);
        imagesList = dir([imgFilePath subPath{iSeq} filesep '*.png']);
        
        % Read the video-images and groundtruth
        frameFirst = imread([imgFilePath subPath{iSeq} filesep imagesList(1).name]);
        video = zeros(size(frameFirst, 1), size(frameFirst, 2), length(imagesList));
        for j=1:length(imagesList)
            video(:,:,j) = imread([imgFilePath subPath{iSeq} filesep imagesList(j).name]);
            
            
        end
        flowFilename = [flowFilePath subPath{iSeq} filesep 'flow10.flo'];
        tuv = readFlowFile(flowFilename);
        
        % obtain the opticalFlow for MODEL A
        flowA = applyOpticalFlowTask4a(uint8(video), '', zeros(size(video,3),1));
        
        % obtain the opticalFlow for MODEL B
        flowB = applyOpticalFlowTask4b(uint8(video), '', zeros(size(video,3),1));
        
        % Evaluate the results
        evalutateResults('A', flowA, tuv, iSeq, 1);
        evalutateResults('B', flowB, tuv, iSeq, 1);
        disp('---------------------------');
        
        
    end
    
    % Function to evaluate the results
    function evalutateResults(strm, flow, tuv, iSeq, VERBOSE)
        for i = 1:size(flow,1)
            % Read test image
            testU = flow{i}.Vx;
            testV = flow{i}.Vy;

            % Mean square error
            gtU = tuv(:,:,1);
            gtV = tuv(:,:,2);
            
            msenAux = sqrt((testU - gtU).^2 + (testV - gtV).^2);          
            gtVal = gtU==0 & gtV==0;
            
            msenAux( gtVal==0 ) = 0;

            pepnAux = msenAux>pepnThresh;
            pepn(i) = sum(pepnAux(:))/sum(gtVal(:));
            msen(i) = sum(msenAux(:))/sum(gtVal(:));
            if VERBOSE
                fprintf( 'Evaluation %s:\n With model %s' , subPath{iSeq}, strm)
                fprintf( '\tMSEN = %f\n\tPEPN = %f\n' , msen(i) , pepn(i))
            end % if
        end % for
    end
end