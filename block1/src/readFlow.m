function [u , v , val ] = readFlow( pathFlow )
%READFLOW Summary of this function goes here
%   Detailed explanation goes here
    
    im = double(imread( pathFlow ));
    u = ( im(:,:,1) - 2^15 )/64;
    v = ( im(:,:,2) - 2^15 )/64;
    val = logical( im(:,:,3) );
    % Ocluded
    u( val==0 ) = 0;
    v( val==0 ) = 0;
end  % function