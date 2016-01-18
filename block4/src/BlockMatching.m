function results = BlockMatching(frame1, frame2, params)
    % Busca bloques del frame1 en el frame 2
    blockResult = blockproc(frame, params.blockSize, @searchSimilarBlock);
    
    % Creamos los resultados
    results.absoluteLocation = blockResult(:,:,4:5);
    results.relativeLocation = blockResult(:,:,2:3);
    results.mse = blockResult(:,:,1);
    
    function data = searchSimilarBlock(block_struct)
        % Se calcula el centro del bloque
        centerBlock = block_struct.location + ceil(block_struct.blockSize/2);
        
        % Se calcula el area de busqueda respecto ese centro y un radio
        % dado
        areaSearch = [centerBlock(1) - params.radiousSearch, ...
            centerBlock(2) - params.radiousSearch, ...
            centerBlock(1) + params.radiousSearch, ...
            centerBlock(2) + params.radiousSearch];
        % Restringimos la busqueda respecto la region de la imagen
        areaSearch = [max(1, areaSearch(1)), max(1, areaSearch(2)), ...
            min(size(x2,1), areaSearch(3)), min(size(x2,2), areaSearch(4))];
        % Convertimos a y,x,altura, anchura
        areaSearch = [areaSearch(1), areaSearch(2), areaSearch(3) - areaSearch(1), areaSearch(4) - areaSearch(2)];
        % imCrop requiere que este en formato x,y,anchura altura, lo
        % flipamos.
        areaSearchFliped = [areaSearch(2), areaSearch(1), areaSearch(4), areaSearch(3)];
        
        % Obtenemos el offset que necesitamos, para encontrar el vector que
        % va desde el bloque1 al bloque2.
        offset = block_struct.location - areaSearch(1:2);
        
        % Recortamos la seccion de busqueda
        imToSearch = imcrop(x2, areaSearchFliped);
        
        % Creamos el objeto que nos permitira obtener los datos que
        % necesitamos
        minBlock = struct('absoluteLocation', [1 1],'relativeLocation', [1 1], 'mse', Inf);
        
        % Recorremos la region de busqueda
        for i=1:params.StepSlidingWindow:(size(imToSearch, 1) - block_struct.blockSize(1)),
            for j=1:params.StepSlidingWindow:(size(imToSearch, 2) - block_struct.blockSize(2)),
                % bloque A (bloque del frame 1)
                blockA = block_struct.data;
                % bloque B (bloque del frame 2 que analizamos)
                blockB = imToSearch(i:(i+block_struct.blockSize(1)), j:(j+block_struct.blockSize(2)));
                
                % Calculamos el tamaño minimo, para evitar que un bloque
                % sea distinto al otro (Esto puede suceder en los bordes de
                % la imagen)
                sizeReal = [min(size(blockA,1), size(blockB,1)), min(size(blockA,2), size(blockB,2))];
               
                % Obtenemos el bloque con esa medida
                blockA = double(blockA(1:sizeReal(1), 1:sizeReal(2)));
                blockB = double(blockB(1:sizeReal(1), 1:sizeReal(2)));
                
                % Calculamos el MSE
                diff = blockA(:) - blockB(:);
                mse = sum(diff.*diff);
                
                if mse < minBlock.mse
                    minBlock.relativeLocation = [i,j] - offset; % Posicion respecto frame1
                    minBlock.absoluteLocation = [i,j] + areaSearch(1:2) -1; % Posicion absoluta en frame2
                    minBlock.mse = mse;
                end
            end
        end
        
        % Devolvemos el objeto en formato de "imagen"
        data = zeros(1,1,5);
        data(:,:,1) = minBlock.mse;
        data(:,:,2:3) = minBlock.relativeLocation;
        data(:,:,4:5) = minBlock.absoluteLocation;
    end
end