function [  ] = opticalFlowTest( opticalFlowFunc, flow, outputPath, pepnThresh, VERBOSE )
%OPTICALFLOWEVALUATION Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('VERBOSE','var')
        VERBOSE = 0;
    end
    
    for i = 1:flow.nSequences
        for j = 1:length(flow.framesInd)
            imName = sprintf('%06d', flow.framesInd(j));
            frames = [];
            % Read all the consecutive frames
            for k = 1:size(flow.framesOrder,1)
                fileName = [ flow.basePaths(i,:) filesep imName flow.framesOrder(k,:) '.png' ];
                frame = imread(fileName);
                if size(frame,3)==3
                    frame = rgb2gray(frame);
                end
                frames(:,:,k) = frame;
            end
            opticalFlowFunc(uint8(frames), [ outputPath imName], flow.framesOrder)
        end
        [ msen , pepn ] = opticalFlowEvaluation( flow.gtFolders , outputPath , '' , pepnThresh , VERBOSE );
        if VERBOSE
            fprintf('AVERAGE:\n\tMSEN= %f\n\tPEPN = %f\n', mean(msen),mean(pepn));
        end
    end
end

