classdef TrackingObjects<handle
    properties
        trackers
        maxDistanceMeasurement
        minDistanceMerge
        mergePenalize
        maxLive
        stepLive
        limits
        timeThres
        timeStopThres
        velocityEstimator
    end
    
    methods
        % Contruccion de la clase trackers
        % Vida Maxima sin aparecer o moverse
        % Distancia minima a la que se considera que una medida se
        % considera que esta dentro de ese objeto.
        %   a) Si es mas pequeño se actualiza el tracking de ese objeto.
        %   b) Sino se crea otro tracking distinto
        function obj = TrackingObjects(limits, maxDistanceMeasurement, minDistanceMerge, mergePenalize, maxLive, stepLive, timeThres, timeStopThres, velocityEstimator)
            obj.trackers = {};
            obj.maxDistanceMeasurement = maxDistanceMeasurement;
            obj.minDistanceMerge = minDistanceMerge^2;
            obj.mergePenalize = mergePenalize;
            obj.maxLive = maxLive;
            obj.stepLive = stepLive;
            obj.limits = limits;
            obj.timeThres = timeThres;
            obj.timeStopThres = timeStopThres;
            obj.velocityEstimator = velocityEstimator;
        end
        
        function [S, CC] = getCentroidsAndCC(obj, mask)
            CC = bwconncomp(mask);
            S = regionprops(CC,'Centroid', 'BoundingBox');
        end
        
        % Comprovar las medidas y si existe ya un tracking de ese objeto
        function checkMeasurements(obj, mask)
            % Obtenemos los centroides i lac
            [objects, CC] = obj.getCentroidsAndCC(mask);
            
            % Creamos una lista de los objetos usados
            objectsUsed = logical(zeros(size(objects, 1), 1, 'uint8'));
            if length(obj.trackers) > 0
%                 % Eliminamos los objetos que ya pertenecen a un tracker
%                 for i=1:length(obj.trackers)
%                     posx = round(obj.trackers{i}.lastpredict(1));
%                     posy = round(obj.trackers{i}.lastpredict(2));
%                     
%                     delObjectsIndex = [];
%                     for j=1:size(objects, 1)
%                         try
%                             if CC(posx, posy) == CC(round(objects.Centroids(1)), round(objects.Centroids(2)))
%                                 delObjectsIndex(end+1) = j;
%                             end
%                         catch
%                             continue
%                         end
%                     end
%                     objects(delObjectsIndex) = [];
%                 end
                
                % Consideramos medidas aquellos objetos que estan cerca
                % Obtenemos todas las distancias
                trackerspoints = zeros(length(obj.trackers), 2);
                for i=1:length(obj.trackers)
                    trackerspoints(i,:) = obj.trackers{i}.lastpredict;
                end

                objectspoints = zeros(size(objects, 1), 2);
                for i=1:size(objects, 1)
                    objectspoints(i,:) = [objects(i).Centroid(1), objects(i).Centroid(2)];
                end
                matrix = pdist2(trackerspoints, objectspoints);

                % Comprovamos cuales de los objectos puedne assignare como
                % "medida" a un tracker (Lo podemos hacer tantas vecemos como
                % trackers haya (O si hay menos objectos que trackers, pues el
                % numero de objectos).                
                for i=1:min(length(obj.trackers), size(objects, 1))
                    [minDistance, ind] = min(matrix(:));
                    [idtracker, idobject] = ind2sub(size(matrix), ind);

                    % El objeto mas cercano comprovamos si esta lo
                    % suficientemente cerca del tracker
                    if minDistance < obj.maxDistanceMeasurement
                       % Indicamos que ese objeto ya no puede ser usado y
                       % tampoco el tracker
                       matrix(idtracker,:) = Inf;
                       matrix(:, idobject) = Inf;
                       objectsUsed(idobject) = true;

                       % Actualizamos el tracker
                       obj.trackers{idtracker}.tracker.update(objects(idobject));
                       % Creamos nuevamente la bb
                       obj.trackers{idtracker}.bb = objects(idobject).BoundingBox(3:4);
                       
                       % Le anadimos vida, para que siga funcionando
                       obj.trackers{idtracker}.live = obj.trackers{idtracker}.live + obj.stepLive;
                       
                       % Incrementamos i
                    end
                end
            end
            
            % Aquellos que no han sido assignados debemos crear un nuevo
            % tracker
            for i=1:size(objects, 1)
                % Comprovamos que no ha sido usado
                if length(obj.trackers) == 0 || objectsUsed(i) == false
                    % Creamos un nuevo tracker para el
                    obj.trackers{end+1} = obj.createNewTracker(objects(i));
                    % Lo assignamos como usado (Es redundante)
                    % objectsUsed(i) = true;
                end
            end
        end
        
        % Crear un nuevo tracker 
        function tracker = createNewTracker(obj, object)
            tracker = struct('live', obj.maxLive, 'tracker', kalmanTracker(object), 'lastpredict', [object.Centroid(1), object.Centroid(2)], 'antlastpredict', [Inf Inf], 'time', 0, 'timeStop', 0, 'bb', object.BoundingBox(3:4), 'accVel', 0);
        end
        
        % Deja passar solo aquellos que tienen vida o se salen de la imagen
        function t = trackerPass(obj, tracker, id)
            t = tracker;
            
            
            % Si lleva mucho tiempo parado incrementamos su contador
            aux = t.lastpredict - t.antlastpredict;
            
            if sum(aux.*aux) < 0.5
                t.timeStop = t.timeStop + 1;
            else
                t.timeStop = 0;
            end
            
            % Si dos trackers estan muy juntos
            for i=(id+1):length(obj.trackers)
                aux = (t.lastpredict - obj.trackers{i}.lastpredict);
                if sum(aux.*aux) < obj.minDistanceMerge
                    % Se decrementa el que lleva menos rato, así
                    % podemos saber si se ha producido ruido
                    if t.time < obj.trackers{i}.time
                        t.live = t.live - obj.mergePenalize;
                    else
                        obj.trackers{i}.live = obj.trackers{i}.live - obj.mergePenalize;
                    end
                end
            end
            
            % Sino tiene vida lo eliminamos
            if tracker.live <= 0
                t = [];
            end
            
            % Si se sale de el rango de coordenadas (imagen) se elimina
            % el tracker se supone que el coche ya no esta en la imagen
            lastpredict = tracker.lastpredict;
            if lastpredict(1) < obj.limits(1,1) || lastpredict(1) > obj.limits(1,2) || lastpredict(2) < obj.limits(2,1) || lastpredict(2) > obj.limits(2,2)
                t = [];
            end
            
        end
        
        % Eliminamos trackers sin vida o se salen de la imagen
        function filterTrackers(obj)
            for i=1:length(obj.trackers)
                obj.trackers{i} = obj.trackerPass(obj.trackers{i}, i);
            end
            obj.trackers(cellfun(@(tracker) isempty(tracker),obj.trackers))=[];
        end
        
        % Obtenemos todos los trackers y predecimos
        function positions = getTrackers(obj, homography)
            % Eliminamos aquellos que no tengan vida
            obj.filterTrackers();
            
            positions = cell(length(obj.trackers), 1);
            for i=1:length(obj.trackers)
                % Actualizamos la ultima prediccion
                prediccion = obj.trackers{i}.tracker.predict();
                obj.trackers{i}.antlastpredict = obj.trackers{i}.lastpredict;
                obj.trackers{i}.lastpredict = prediccion;
                
                % introducimos el codigo
                % Si lleva muy poco rato, puede ser ruido
                if obj.timeThres > obj.trackers{i}.time
                    code = 'notVehicleYet';
                elseif obj.timeStopThres < obj.trackers{i}.timeStop
                    code = 'inactive';
                else
                    code = 'active';
                end
                
                % Estimacion de la velocidad
                velocity = obj.predictVelocity(homography, obj.trackers{i});
                obj.trackers{i}.accVel = obj.trackers{i}.accVel + velocity;
                
                
                positions{i} = struct('location', prediccion, 'code', code, 'bb', obj.trackers{i}.bb, 'vel', velocity, 'avgVel', obj.trackers{i}.accVel/obj.trackers{i}.time);
                % Quitamos vida a todos los trackers
                obj.trackers{i}.live = obj.trackers{i}.live - 1;
                obj.trackers{i}.time = obj.trackers{i}.time + 1;
                
            end
        end
        
        
        % Predict velocity
        % Para predecir la velocidad haremos uso de la homografia
        function vel = predictVelocity(obj, homography, tracker)
            velP = [tracker.lastpredict; tracker.antlastpredict];
            velPReal = homography.pointsImage2H(velP);
            
            vel = (velPReal(1,:) - velPReal(2,:));
            vel = sqrt(sum(vel.*vel))*obj.velocityEstimator;
        end
        
        
        % Mostramos los resultados
        function showTrackers(obj, im, mask, positions)
            % Imagen Original
            subplot(1,2,1), imshow(im), hold on;
            codes = {};
            
            k = 0;
            for i=1:length(positions)
                pos = positions{i};
                loc = pos.location;
                code = pos.code;

                if strcmp(code, 'inactive')
                    n = 'Inactive';
                    c = 'r';
                elseif strcmp(code, 'notVehicleYet')
                    n = 'Not Vehicle Yet';
                    c = 'b';
                elseif strcmp(code, 'active')
                    k = k + 1;
                    n = 'Active';
                    c = 'g';
                end
                plot(loc(1), loc(2), [c '*']);
                codes{end+1} = n;
                
                if strcmp(code, 'active')
                    codes{end} = [codes{end} '  num: ' num2str(k) ', vel: ' num2str(round(positions{i}.vel)) ', avgVel: ', num2str(round(positions{i}.avgVel))];
                end
                
                if strcmp('Active', n)
                    thisBB = positions{i}.bb;
                    rectangle('Position', [loc(1) - thisBB(1)/2, loc(2) - thisBB(2)/2, thisBB(1), thisBB(2)], 'EdgeColor',c,'LineWidth',2);
                end
            end
            legend(codes, 'Location', 'NorthOutside')
            hold off;

            % Mascara
            subplot(1,2,2), imshow(mask), hold on;
            for i=1:length(positions)
                pos = positions{i};
                loc = pos.location;
                code = pos.code;

                if strcmp(code, 'inactive')
                    c = 'r*';
                elseif strcmp(code, 'notVehicleYet')
                    c = 'b*';
                elseif strcmp(code, 'active')
                    c = 'g*';
                end
                plot(loc(1), loc(2), c);
            end
            hold off;

            pause(0.00001);
        end
        
        
        
        
        
    end
    
end