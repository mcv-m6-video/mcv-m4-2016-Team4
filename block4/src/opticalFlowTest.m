function [  ] = opticalFlowTest( opticalFlowFunc, flow, outputPath, pepnThresh, VERBOSE )
%OPTICALFLOWEVALUATION Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('VERBOSE','var')
        VERBOSE = 0;
    end
    flowImagesCell = cell(0,0);
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
            [ flowImages, GT_files] = opticalFlowFunc(uint8(frames), [ outputPath imName], flow.framesOrder);
            % Pack the flow images in a cell
            for l=1:size(flowImages,1)
                flowImagesCell{end+1,1} = flowImages{l};
                flowImagesCell{end,2} = GT_files{l};
            end
        end
        
        [ msen , pepn ] = opticalFlowEvaluationIm( flow.gtFolders , flowImagesCell , '' , pepnThresh , VERBOSE );
        if VERBOSE
            fprintf('AVERAGE:\n\tMSEN= %f\n\tPEPN = %f\n', mean(msen),mean(pepn));
        end
    end
end

