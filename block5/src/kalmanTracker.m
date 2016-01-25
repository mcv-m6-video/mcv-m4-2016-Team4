classdef kalmanTracker
    % atributos
    properties(Access = private)
        kalman
        t
        estadoModelo
        medidasModelo
    end
    
    % metodos
    methods
        % Constructor
        function obj = kalmanTracker(objeto)           
            % Escribimos las equaciones del movimiento lineal
            % x(t) = x0 + vx*t (suponemos velocidad constante)
            % y(t) = y* + vy*t
            % Formato matriz:
            % [x]      [1 0 t 0 0 0][x]
            % [y]    = [0 1 0 t 0 0][y]
            % [dx]     [0 0 1 0 0 0][dx]
            % [dy]     [0 0 0 1 0 0][dy]
            % [bw]     [0 0 0 0 1 0][bw]
            % [bh]     [0 0 0 0 0 1][dh]

            obj.t = 1;
            obj.estadoModelo = [1 0 obj.t 0 0 0;
                            0 1 0 obj.t 0 0;
                            0 0 1 0 0 0;
                            0 0 0 1 0 0;
                            0 0 0 0 1 0;
                            0 0 0 0 0 1];

            % Matriz que transforma un estado en una observacion
            % x = x + 0*y + 0*dx + 0*dy
            % y = 0*x + y + 0*dx + 0*dy
            % [x] = [1 0 0 0][x]
            % [y]   [0 1 0 0][y]
            %                [dx]
            %                [dy]
            obj.medidasModelo = [1 0 0 0 0 0;
                             0 1 0 0 0 0;
                             0 0 0 0 1 0;
                             0 0 0 0 0 1];

            % No hay matriz de control (Se supone que sirve para cuando entra un
            % estimulo, que perturba el funcionamiento normal).

            % La matriz Q es la matriz de covarianzas que modeliza el ruido que se
            % produce en el modelo.
            % En nuestro caso la matriz seria de 4x4, pero no sabemos como se produce
            % el ruido entre x-y, o x-dx. Así que usaremos una constante en la diagonal
            Q = 1e-4; % Margen de error de un estado a otro.

            % La matriz R es la matriz que modeliza el ruido que se producen en las
            % mediciones, nos aparece la misma duda que en la Q, así que ponemos una
            % constante en la diagonal.
            R = 5; % La varianza en las estimaciones son de 5. Es tu margen de error, 5 pixeles.

            % El estado inicial del objeto a seguir
            estadoInicial = [objeto.Centroid, 0, 0, objeto.BoundingBox(3), objeto.BoundingBox(4)];

            % Iniciamos kalman
            obj.kalman = vision.KalmanFilter(obj.estadoModelo, obj.medidasModelo, 'ProcessNoise', Q, 'MeasurementNoise', R, 'State', estadoInicial);
        end
        
        % anadir una nueva medida al modelo
        function update(obj, objeto)
            correct(obj.kalman, [objeto.Centroid, objeto.BoundingBox(3:4)]);
        end
        
        % predecir la posicion
        function objeto = predict(obj)
           [~, objeto] = predict(obj.kalman);
        end
        
        % distancia entre una medida i la estimacion
        function d = distance(obj, objeto)
            d = distance(obj.kalman, [objeto.Centroid, objeto.BoundingBox(3:4)]);
        end
end
    
end