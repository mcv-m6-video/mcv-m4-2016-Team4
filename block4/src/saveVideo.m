function saveVideo(filename, video)
    vid = VideoWriter(filename,'Uncompressed AVI');
    
    open(vid);
    writeVideo(vid,video)
%     for p=1:size(video,ndims(video))
%         M(p)=im2frame(video(:,:,:,p));
%     end
    close(vid);
end