    function [imOut, t] = imHomography(im, line1, line2)
    function v = vanishPoint(line1, line2)
        r1c = cross([line1(2,:) 1]', [line1(1,:) 1]');
        r2c = cross([line2(2,:) 1]', [line2(1,:) 1]');
        v = cross(r1c, r2c);
        v = v/v(3);
    end

    function H = vanish2H(v)
        H= [1 -v(1)/v(2) 0; 0 1 0; 0 -1/v(2) 1];
    end

    function H = usingVanishPoint(line1, line2)
        v = vanishPoint(line1, line2);
        H = vanish2H(v);
    end
% 
%     function H = usingParallelLines(line1, line2)
%         x1 = [line1(:,1); line2(:,1)];
%         y1 = [line1(:,2); line2(:,2)];
%         
%         % Found the max HORITZONTAL distance between lines:
%         distX = norm([x1(1) y1(1)] - [x1(2) y1(2)]);
%         distY = norm([x1(1) y1(1)] - [x1(3) y1(3)]);
%         
%         x2 = [x1(2) x1(2) x1(2)+distX x1(2)+distX]';
%         y2 = [y1(2)+distY y1(2) y1(2)+distY y1(2)]';
% 
%         M=[];
%         for i=1:4
%             M=[M;
%                 x1(i), y1(i), 1, 0, 0, 0, -x2(i)*x1(i), -x2(i)*y1(i), -x2(i);
%                 0, 0, 0, x1(i), y1(i), 1, -y2(i)*x1(i), -y2(i)*y1(i), -y2(i)];
%         end
%         % Soluciono el sistema
%         [~,~,v] = svd( M );
%         H = reshape( v(:,end), 3, 3 )';
%         H = H / H(3,3);
% 
%     end
% 
%     function H = findHomographyMatrix(line1,line2)
%         % Sort the coordinates
%         [~, id] = sort(line1(:,2), 'descend'); line1 = line1(id, :);
%         [~, id] = sort(line2(:,2), 'descend'); line2 = line2(id, :);
%         
%         H = usingVanishPoint(line1, line2);
%     end
    
    [~, id] = sort(line1(:,2), 'descend'); line1 = line1(id, :);
    [~, id] = sort(line2(:,2), 'descend'); line2 = line2(id, :);

    %H = transpose(findHomographyMatrix(line1, line2));
    %t = projective2d(H);
%    x1 = [line1(:,1); line2(:,1)];
%    y1 = [line1(:,2); line2(:,2)];
    
%     meanX1point = mean(line1, 1);
%     meanX2point =  mean(line2, 1);
%     
%     line1new = [meanX1point(2), line1(1,2); meanX1point(2), line1(2,2)];
%     line2new = [meanX2point(2), line1(1,2); meanX2point(2), line1(2,2)];
%     x2 = [line1new(:,1); line2new(:,1)];
%     y2 = [line1new(:,2); line2new(:,2)];
    
    H = transpose(usingVanishPoint(line1, line2));
       
    t = projective2d(H); %fitgeotrans([x1, y1],[x2,y2],'projective');
    imOut = imwarp(im,t);
end

%% SELECT POINTS
% figure(1),imshow(im), title('Select the left line:');
% [x, y] = ginput(2);
% line1 = [x, y];
% figure(1),imshow(im), title('Select the right line:');
% [x, y] = ginput(2);
% line2 = [x, y]; 
% imOut = imHomography(im1, line1, line2);