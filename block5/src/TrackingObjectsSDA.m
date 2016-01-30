classdef TrackingObjectsSDA<handle
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
        fps
        
        historyNum
        historialTrackersList
    end
    
    methods
        % Contruccion de la clase trackers
        % Vida Maxima sin aparecer o moverse
        % Distancia minima a la que se considera que una medida se
        % considera que esta dentro de ese objeto.
        %   a) Si es mas pequeño se actualiza el tracking de ese objeto.
        %   b) Sino se crea otro tracking distinto
        function obj = TrackingObjectsSDA(limits, maxDistanceMeasurement, minDistanceMerge, mergePenalize, maxLive, stepLive, timeThres, timeStopThres, velocityEstimator, fps)
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
            obj.fps = fps;
            
            obj.historyNum = 0;
            obj.historialTrackersList = {};
        end
        
        function obj = setVelocityEstimator(obj, velEst)
            obj.velocityEstimator = velEst;
        end
        
        function [S, CC] = getCentroidsAndCC(obj, mask)
            CC = bwconncomp(mask);
            S = regionprops(CC,'Centroid', 'BoundingBox');
        end
        
        
        
        % Comprovar las medidas y si existe ya un tracking de ese objeto
        function checkMeasurements(obj, mask, im)
            % Obtenemos los centroides i lac
            [objects, CC] = obj.getCentroidsAndCC(mask);
            
            % Creamos una lista de los objetos usados
            objectsUsed = false(size(objects, 1), 1);
            if ~isempty(obj.trackers)
                % Consideramos medidas aquellos objetos que estan cerca
                % Obtenemos todas las distancias
                trackerspoints = zeros(length(obj.trackers), 2);
                for i=1:length(obj.trackers)
                    trackerspoints(i,:) = obj.trackers{i}.lastpredict.position;
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
                       
                       % Si la bounding box encontrada es mas grande que la
                       % actual, suponemos que la anterior era ruido y
                       % copiamos la informacion
                       if 0.4*prod(objects(idobject).BoundingBox(3:4)) > prod(obj.trackers{idtracker}.lastpredict.BoundingBoxWH(1:2))
                            obj.trackers{idtracker}.tracker = obj.createSDAObj(objects(idobject), im);
                       end

                       % Le anadimos vida, para que siga funcionando
                       obj.trackers{idtracker}.live = obj.trackers{idtracker}.live + obj.stepLive;
                    end
                end
            end
            
            % Aquellos que no han sido assignados debemos crear un nuevo
            % tracker
            for i=1:size(objects, 1)
                % Comprovamos que no ha sido usado
                if isempty(obj.trackers) || objectsUsed(i) == false
                    % Creamos un nuevo tracker para el
                    obj.trackers{end+1} = obj.createNewTracker(objects(i), im);
                    % Lo assignamos como usado (Es redundante)
                    % objectsUsed(i) = true;
                end
            end
        end
        
        % crear un struct de prediccion
        function predict = createPredictStruct(obj, array)
            predict = struct('position', [array(1) array(2)], 'velocity', [array(3) array(4)], 'BoundingBoxWH', [array(5) array(6)]);
        end
        
        % Crear un sdaObject
        function sdaObject = createSDAObj(obj, object, im)
            % Creamos un SDAFilter
            sdaObject = SDAFilter(im, object.BoundingBox);
        end
        
        % Crear un nuevo tracker 
        function tracker = createNewTracker(obj, object, im)     
            sdaObject = obj.createSDAObj(object, im);
            
            lastpredict = obj.createPredictStruct([object.Centroid(1) object.Centroid(2), 0, 0, object.BoundingBox(3) object.BoundingBox(4)]);
            antlastpredict = obj.createPredictStruct([Inf, Inf, 0, 0, object.BoundingBox(3) object.BoundingBox(4)]);
            
            
            % Creamos el tracker
            obj.historyNum = obj.historyNum + 1;
            tracker = struct('live', obj.maxLive, 'tracker', sdaObject, 'lastpredict', lastpredict, 'antlastpredict', antlastpredict, 'time', 0, 'timeStop', 0, 'accVel', 0, 'timeActive', 0, 'id', obj.historyNum); % 'bb', object.BoundingBox(3:4)
        end
        
        % Deja passar solo aquellos que tienen vida o se salen de la imagen
        function t = trackerPass(obj, tracker, id)
            t = tracker;
                        
            % Si lleva mucho tiempo parado incrementamos su contador
            normVel = t.lastpredict.position - t.antlastpredict.position;
            normVel = sum(normVel.*normVel);
            
            if normVel < 0.5
                t.timeStop = t.timeStop + 1;
            else
                t.timeStop = 0;
            end
            
            % Si dos trackers estan muy juntos
            for i=(id+1):length(obj.trackers)
                distance = (t.lastpredict.position - obj.trackers{i}.lastpredict.position);
                distance = sum(distance.*distance);
                if distance < obj.minDistanceMerge
                    % Se decrementa el que lleva menos rato, así
                    % podemos saber si se ha producido ruido
                    if t.timeActive < obj.trackers{i}.timeActive
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
            if tracker.lastpredict.position(1) < obj.limits(1,1) || tracker.lastpredict.position(1) > obj.limits(1,2) || ...
                    tracker.lastpredict.position(2) < obj.limits(2,1) || tracker.lastpredict.position(2) > obj.limits(2,2)
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
        function positions = getTrackers(obj, im, homography)
            % Eliminamos aquellos que no tengan vida
            obj.filterTrackers();
            
            positions = cell(length(obj.trackers), 1);
            for i=1:length(obj.trackers)
                % Actualizamos la ultima prediccion
                [obj.trackers{i}.tracker, bb, bbCenter, results] = obj.trackers{i}.tracker.estimatePosition(im);
                obj.trackers{i}.antlastpredict = obj.trackers{i}.lastpredict;
                obj.trackers{i}.lastpredict = obj.createPredictStruct([bbCenter(1), bbCenter(2), 0, 0, bb(3), bb(4)]);
                
                % Estimacion de la velocidad
                velocity = obj.predictVelocity(homography, obj.trackers{i});
                    
                % introducimos el codigo
                % Si lleva muy poco rato, puede ser ruido
                if obj.timeThres > obj.trackers{i}.time
                    code = 'notVehicleYet';
                    obj.trackers{i}.timeActive = 0;
                    obj.trackers{i}.accVel =  0;
                    
                elseif obj.timeStopThres < obj.trackers{i}.timeStop
                    code = 'inactive';
                    obj.trackers{i}.timeActive = 0;
                    obj.trackers{i}.accVel =  0;
                    
                else
                    code = 'active';
                    obj.trackers{i}.timeActive = obj.trackers{i}.timeActive  + 1;
                    
                    obj.trackers{i}.accVel = obj.trackers{i}.accVel + velocity;
                end
                
                
                
                
                positions{i} = struct('location', obj.trackers{i}.lastpredict.position, 'code', code, ...
                    'BoundingBoxWH', obj.trackers{i}.lastpredict.BoundingBoxWH, 'vel', velocity, 'avgVel', ...
                    obj.trackers{i}.accVel/obj.trackers{i}.timeActive, 'id', obj.trackers{i}.id);
                % Quitamos vida a todos los trackers
                obj.trackers{i}.live = obj.trackers{i}.live - 1;
                obj.trackers{i}.time = obj.trackers{i}.time + 1;
                
            end
        end
        
        
        % Predict velocity
        % Para predecir la velocidad haremos uso de la homografia
        % Es mejor usar la posicion porque la velocidad se va acumulando en
        % el filtro de kalman y se acumula tambien cuando no esta 'Active'
        function vel = predictVelocity(obj, homography, tracker)
%             velP = tracker.lastpredict.position - tracker.antlastpredict.position;
%             vel = homography.distImage2H(velP);
%             vel = sqrt(sum(vel.*vel))*obj.velocityEstimator*obj.fps*3.6;
            vel = homography.dist2Points(tracker.lastpredict.position, tracker.antlastpredict.position);
            vel = vel*obj.velocityEstimator*obj.fps*3.6;
        end
        
        % Guardamos el historial
        function historialTrackers(obj, positions)
            for i=1:length(positions)
                if strcmp(positions{i}.code, 'active')
                    obj.historialTrackersList{positions{i}.id} = struct('id', positions{i}.location, 'location', positions{i}.location, 'avgVel', positions{i}.avgVel);
                end
            end
        end
        
        % Funcion para poder ver el historial
        function [realHisto, total] = getHistorial(obj)
            realHisto = {};
            k=1;
            for i=1:length(obj.historialTrackersList)
                if ~isempty(obj.historialTrackersList{i})
                    realHisto{k} = obj.historialTrackersList{i};
                    realHisto{k}.id = k;
                    k=k+1;
                end
            end
            total = k-1;
        end
        
        % Mostramos los resultados
        function showTrackers(obj, im, mask, positions)
            % Imagen Original
            subplot(1,2,1), imshow(im), hold on;
            codes = {};
            activeBBhandles = [];
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
                    codes{end+1} = n;
                end
                h = plot(loc(1), loc(2), [c '*']);
                
                
                if strcmp(code, 'active')
                    activeBBhandles(end+1) = h;
                    codes{end} = [codes{end} '  num: ' num2str(k) ', vel: ' num2str(round(positions{i}.vel)) ', avgVel: ', num2str(round(positions{i}.avgVel))];
                end
                
                if strcmp('Active', n)
                    thisBB = positions{i}.BoundingBoxWH;
                    text(loc(1) + thisBB(1)/2 + 5, loc(2), num2str(k), 'Color', 'green', 'FontSize', 18)
                    rectangle('Position', [loc(1) - thisBB(1)/2, loc(2) - thisBB(2)/2, thisBB(1), thisBB(2)], 'EdgeColor',c,'LineWidth',2);
                end
            end
            
            if ~isempty(codes)
                legend(activeBBhandles, codes, 'Location', 'NorthOutside')
            end
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