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
                'Grove2', 'Grove3', 'Urban2', 'Urban3'};%, ...
                %NO TIENEN GT 'Walking', 'Beanbags',     'DogDance',     'MiniCooper'};
    
    allPepnA = {};
    allPepnB = {};
    
    allMsenA = {};
    allMsenB = {};
    
    for iSeq=1:length(subPath),
        disp(['Sequence : ' subPath{iSeq}]);
        imagesList = dir([imgFilePath subPath{iSeq} filesep '*.png']);
        
        % Read the video-images and groundtruth
        frameFirst = imread([imgFilePath subPath{iSeq} filesep imagesList(1).name]);
        video = zeros(size(frameFirst, 1), size(frameFirst, 2), length(imagesList));
        tuv = zeros(size(frameFirst, 1), size(frameFirst, 2), 2, length(imagesList)-1);
        for j=1:length(imagesList)
            video(:,:,j) = imread([imgFilePath subPath{iSeq} filesep imagesList(j).name]);
            id = regexp(imagesList(1).name, 'frame(?<id>[0-9]+)\.png','names');
            
            % Siempre habra un optical flow menos que el tamano total de
            % imagenes
            if j<length(imagesList)
                flowFilename = [flowFilePath subPath{iSeq} filesep 'flow' id.id '.flo'];
                tuv(:,:,:,j) = readFlowFile(flowFilename);
            end
            
            
        end
        
        % obtain the opticalFlow for MODEL A
        flowA = applyOpticalFlowTask4a(uint8(video), '', zeros(size(video,3),1));
        
        
        % obtain the opticalFlow for MODEL B
        flowB = applyOpticalFlowTask4b(uint8(video), '', zeros(size(video,3),1));
        
        % Evaluate the results
        [pepnA, msenA] = evalutateResults('A', flowA, tuv, iSeq, 1);
        [pepnB, msenB] = evalutateResults('B', flowB, tuv, iSeq, 1);
        disp('---------------------------');
        
        allPepnA{iSeq} = pepnA;
        allPepnB{iSeq} = pepnB;
        
        allMsenA{iSeq} = msenA;
        allMsenB{iSeq} = msenB;
    end
    
    % Saving the results
    save('TASK4_RESULTS', 'allPepnA', 'allPepnB', 'allMsenA', 'allMsenB', 'subPath');
    
    % Function to evaluate the results
    function [pepn, msen] = evalutateResults(strm, flow, tuv, iSeq, VERBOSE)
        for i = 1:size(flow,1)
            % Read test image
            testU = flow{i}.Vx;
            testV = flow{i}.Vy;

            % Mean square error
            gtU = squeeze(tuv(:,:,1,:));
            gtV = squeeze(tuv(:,:,2,:));
            
            msenAux = sqrt((testU - gtU).^2 + (testV - gtV).^2);          
            gtNotVal = abs(gtU)>1e9 | abs(gtV)>1e9;
            gtVal = ~gtNotVal;
            
            msenAux( gtNotVal ) = 0;

            pepnAux = msenAux>pepnThresh;
            pepn(i) = sum(pepnAux(:))/sum(gtVal(:));
            msen(i) = sum(msenAux(:))/sum(gtVal(:));
            if VERBOSE
                fprintf( 'Evaluation %s:\n With model %s' , subPath{iSeq}, strm)
                fprintf( '\tMSEN = %f\n\tPEPN = %f\n' , msen(i) , pepn(i))
            end % if
        end % for
    end
    rmpath(genpath('flow_code'));
end