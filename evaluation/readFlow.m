function [u , v , val ] = readFlow( pathFlow )
%READFLOW Given a path of a flow file, extract the components (u,v) and 
% the valid non-occluded pixels.
    
    im = double(imread( pathFlow ));
    u = ( im(:,:,1) - 2^15 )/64;
    v = ( im(:,:,2) - 2^15 )/64;
    val = logical( im(:,:,3) );
    % Ocluded
    u( val==0 ) = 0;
    v( val==0 ) = 0;
end  % function