function [ tp , fp , fn , tn, totalForeground, totalBackground ] = segmentationEvaluation( groundtruth, masks , maskNames , VERBOSE )
%SEGMENTATIONEVALUATION Evaluates one folder
%   Recieve the information:
%       * groundtruth: Path to the ground truth or ground truth itself (NxMxK matrix, like 'masks').
%       * masks: NxMxK matrix, where N and M are the size of the
%            frames processed and K are the numbers of frames. For example, 
%            300x300x10 means that there are 10 frames of size 300x300.
%       * maskNames: K cell array containing the names of every mask, so it
%         can be later evaluated by relating the mask to a ground truth image.
%       * VERBOSE: Plot further information.
%   The output are:
%       * True Positives (TP)
%       * False Positives (FP)
%       * True Negatives (FN)
%       * False Negatives (TN)
    if ~exist( 'VERBOSE' , 'var' )
        VERBOSE = false;
    end % if
    
    % Read ground truth
    if ischar(groundtruth)
       % The ground truth is a path. We must load all GT masks.
       gtMasks = zeros(size(masks), 'like', masks);
       for i=1:size(masks,3)
           if ~exists('maskNames','var')
               error('If groundtruth is a path, maskNames parameter needs to be specified.');
           end
            % Read Ground truth image
            numFile = maskNames{i};
            nameGroundtruth = [numFile '.png'];
            gtMasks(:,:,i) = imread( [ pathGroundtruth  nameGroundtruth] );
       end
    else
        % The ground truth is already loaded
        gtMasks = groundtruth;
    end
    
    % Setup variables
    tp = zeros(size(masks,3),1);
    fp = zeros(size(masks,3),1);
    tn = zeros(size(masks,3),1);
    fn = zeros(size(masks,3),1);
    totalForeground = zeros(size(masks,3),1);
    totalBackground = zeros(size(masks,3),1);
    
    % Annotations on the groundtruth
    %     0 : Static
    %     50 : Hard shadow
    %     85 : Outside region of interest
    %     170 : Unknown motion (usually around moving objects, due to semi-transparency and motion blur)
    %     255 : Motion
    % We will use:
    %     Background: 0, 50
    %     Foreground: 255
    %     Unknown (not evaluated): 85, 170 
    for i = 1:size(masks,3)
        % Read test image
        im_test = masks(:,:,i);

        % Segment Ground truth image
        im_gt = gtMasks(:,:,i);
        foreground = im_gt == 255;
        background = im_gt==0 | im_gt==50;

        % Compare both images
        tp(i) = tp(i) + sum( sum( im_test .* foreground ) );
        fp(i) = fp(i) + sum( sum( im_test .* background ) );
        tn(i) = tn(i) + sum( sum( (~im_test) .* background ) );
        fn(i) = fn(i) + sum( sum( (~im_test) .* foreground ) );

        % Compute total foreground and total background
        totalForeground(i) = totalForeground(i) + sum( sum( foreground ) );
        totalBackground(i) = totalBackground(i) + sum( sum( background ) );
    end % for
    
    if VERBOSE
        [ p , r , f1 ] = getMetrics( sum( tp ) , sum( fp ) , sum( fn ) , sum( tn ) );
        fprintf( 'Test %s:\n' , testId );
        fprintf( '\ttp = %d , fp = %d , fn = %d , tn = %d\n' , sum( tp ) , sum( fp ) , sum( fn ) , sum( tn ) );
        fprintf( '\tPrecision = %f , Recall = %f , F1-score = %f\n' , p , r , f1 );
    end

end