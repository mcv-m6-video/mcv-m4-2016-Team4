function outputVideo = stabilizeVideo(video, optFlow)
% Stabilizes video with opticalFlowFunc.
% Input: - video: NxMxK matrix where NxM is the size of the frames and K is
%                 the total amount of frames.
%        - optFlow: optical flow estimation for every pair of frames.
    
    outputVideo = zeros(size(video),'like',video);
    
    % Define similarity matrix (scale, rotation, translation)
    simMatrix = @(tx, ty, theta, s) [s*cos(theta)  s*-sin(theta) 0;
                                     s*sin(theta)  s*cos(theta)  0;
                                     tx            ty            1];
    
    outputVideo(:,:,1) = video(:,:,1);
    % Matrix that will define the transformation from a frame t+1 to a
    % frame t
    tform = affine2d(eye(3));
    for i = 1:length(optFlow) 
        % Note: opticalFlow{i} corresponds to the optFlow of frame i to
        % frame i+1
        tx = mean(mean(optFlow{i}.Vx));
        ty = mean(mean(optFlow{i}.Vy));
        %theta = mean(mean(optFlow{i}.Orientation));
        
%         x = sum(cos(optFlow{i}.Orientation(:)))/numel(optFlow{i}.Orientation(:));
%         y = sum(sin(optFlow{i}.Orientation(:)))/numel(optFlow{i}.Orientation(:));
% 
%         theta = atan2(y, x);
        theta = 0;
        % Acumulate transformation in the transformation matrix so that
        % frame T is warped to frame 1.
        %NO FUNCIONA BÉ ENCARA. Crec que les coordenades del LK no són les
        %correctes. La theta també és molt exagerada, rota molt la imatge.
        %tform.T = tform.T*simMatrix(-tx, -ty, -theta, 1);

        [X,Y] = meshgrid(1:size(optFlow{i}.Vx,2), 1:size(optFlow{i}.Vx,1));
        M=[X(:), Y(:)];
        M2=[double(optFlow{i}.Vx(:)), double(optFlow{i}.Vy(:))];
        aux = estimateGeometricTransform(M+M2, M, 'affine');
        tform.T = tform.T*aux.T;
        % El imwarp retorna una imatge que pot ser de dimensions diferents
        % que l'outputVideo, s'ha de retallar
        Rinput = imref2d(size(video(:,:,i)));
        outputVideo(:,:,i+1) = imwarp(video(:,:,i+1), tform,'OutputView',Rinput);
    end
end