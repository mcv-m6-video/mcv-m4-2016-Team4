classdef Homography<handle
    properties
        tform
        ref
    end
    
    methods
        % Obtener la homografia
        function obj = Homography()
        end
        
        function [line1, line2] = getLinesFigure(obj, im)
            figure(1),imshow(im), title('Select the left line:');
            [x, y] = ginput(2);
            line1 = [x, y];
            figure(1),imshow(im), title('Select the right line:');
            [x, y] = ginput(2);
            line2 = [x, y];
            
            [~, id] = sort(line1(:,2), 'descend'); line1 = line1(id, :);
            [~, id] = sort(line2(:,2), 'descend'); line2 = line2(id, :);
        end
        
        % Obtener mediante el punto de fuga
        function v = vanishPoint(obj, line1, line2)
            r1c = cross([line1(2,:) 1]', [line1(1,:) 1]');
            r2c = cross([line2(2,:) 1]', [line2(1,:) 1]');
            v = cross(r1c, r2c);
            v = v/v(3);
        end
        
        % Obtener la matriz H mediante el punto de fuga
        function H = vanish2H(obj, v)
            H= transpose([1 -v(1)/v(2) 0; 0 1 0; 0 -1/v(2) 1]);
        end
        
        % Obtener las lineas de una imagen i la homografia
        function doTFORMVanishPoint(obj, im)
            [line1, line2] = obj.getLinesFigure(im);
            H = obj.vanish2H(obj.vanishPoint(line1, line2));
            obj.tform = projective2d(H);
            
            % Mostramos el resultado
            imOut = obj.doHomography(im);
            imshow(imOut), title('This is the result, press space to continue...'), pause;
        end
        
        % Apply homography image
        function imOut = doHomography(obj, im)
            [imOut, refe] = imwarp(im, obj.tform);
            obj.ref = refe;
        end
        
        function imOut = doInvertHomography(obj, im)
            [imOut, refInverte] = imwarp(im, obj.tform.invert);
            obj.refInvert = refInverte;
        end
        
        % Distance in Homography to initial Image
        function rpoints = distH2Image(obj, dists)
            [x1,y1] = transformPointsForward(obj.tform.invert, dists(:, 1), dists(:,2));
            rpoints = [x1, y1];
        end
        
        % Distance in initial Image to Homography
        function rpoints = distImage2H(obj,dists)
            [x1,y1] = transformPointsForward(obj.tform, dists(:, 1), dists(:,2));
            rpoints = [x1, y1];
        end
        
        % Point in Homography to initial Image
        function rpoints = pointsH2Image(obj, points)
            [x1,y1] = transformPointsForward(obj.tform.invert, points(:, 1), points(:,2));
            x1 = x1 - obj.refInvert.XWorldLimits(1);
            y1 = y1 - obj.refInvert.YWorldLimits(1); 
            rpoints = [x1, y1];
        end
        
        % Point in initial Image to Homography
        function rpoints = pointsImage2H(obj,points)
            [x1,y1] = transformPointsForward(obj.tform, points(:, 1), points(:,2));
            x1 = x1 - obj.ref.XWorldLimits(1);
            y1 = y1 - obj.ref.YWorldLimits(1); 
            rpoints = [x1, y1];
        end
    end
end