function [ tp , fp , fn , tn ] = segmentationEvaluation( pathGroundtruth , pathResults , test , VERBOSE )
%SEGMENTATIONEVALUATION Evaluates one folder
%   Recieve the information:
%       * pathGroundtruth: Path to the ground truth.
%       * pathResults: Path to the results to evaluate
%       * test: Test id for identifying the files in pathResults.
%       * VERBOSE: Plot further information.
%   The output are:
%       * True Positives (TP)
%       * False Positives (FP)
%       * True Negatives (FN)
%       * False Negatives (TN)

    % If no test is provided, we assume that we have to compute it for the
    % whole folder
    if ~exist( 'test' , 'var' )
        test = '*';
    end % if
    if ~exist( 'VERBOSE' , 'var' )
        VERBOSE = false;
    end % if
    
    % List of files for the test
    filesResultsTest = dir([ pathResults , test ]);
    
    % Setup variables
    tp = zeros(length(filesResultsTest),1);
    fp = zeros(length(filesResultsTest),1);
    tn = zeros(length(filesResultsTest),1);
    fn = zeros(length(filesResultsTest),1);
        
    % String to delete in the path to get the ground truth image
    strToDel = strrep(test,'*','');
    
    % Annotations on the groundtruth
    %     0 : Static
    %     50 : Hard shadow
    %     85 : Outside region of interest
    %     170 : Unknown motion (usually around moving objects, due to semi-transparency and motion blur)
    %     255 : Motion
    for i = 1:length(filesResultsTest)
        % Read test image
        im_test = imread( [ pathResults filesResultsTest(i).name ] );
        im_test = logical( im_test );
        
        % Read Ground truth image
        im_gt = imread( [ pathGroundtruth strrep(filesResultsTest(i).name,strToDel,'') ] );
        im_gt = im_gt == 255;
        
        % Compare both images
        tp(i) = tp(i) + sum( sum( im_test .* im_gt ) );
        fp(i) = fp(i) + sum( sum( im_test .* (~im_gt) ) );
        tn(i) = tn(i) + sum( sum( (~im_test) .* (~im_gt) ) );
        fn(i) = fn(i) + sum( sum( (~im_test) .* im_gt ) );
    end % for
    
    if VERBOSE
        [ p , r , f1 ] = getMetrics( sum( tp ) , sum( fp ) , sum( fn ) , sum( tn ) );
        fprintf( 'Test %s:\n' , strToDel );
        fprintf( '\ttp = %d , fp = %d , fn = %d , tn = %d\n' , sum( tp ) , sum( fp ) , sum( fn ) , sum( tn ) );
        fprintf( '\tPrecision = %f , Recall = %f , F1-score = %f\n' , p , r , f1 );
    end

end