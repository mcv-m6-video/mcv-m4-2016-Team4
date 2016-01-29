%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 5 of the
% project.
% 

%% Setup
setup;

%% Config
enable_homography = 'false'; % 'before', 'false'

%% Morpho in learn Detector
morphoForegroundFunction = @foregroundMorpho;

%% Morpho to detect objects
morphoObjDetectionFunction = @detectionMorpho;

%% Learn foreground estimator and apply homography
% Primero aprendemos el modelo para estimar que son coches y que no.
learnDetector;


%% Read the rest of the sequence
idSequenceDemo = {setdiff(1:1700, idSequenceLearn{1}); setdiff(1:1570, idSequenceLearn{2})};


addpath(genpath('Wang2013/'));
% El pipeline debera ser:
% - Segmentar la imagen (usando el detector de foreground)
% - Aplicar morphologia para separar varios coches (multipleObjectsMorpho)
% - Aplicar un algoritmo de componentes conexas
% - Aplicar kalman por cada componente conexa.
%       a) Si aparece una nueva componente conexa, se debera comprovar si
%       esta cerca de algun filtro de kalman (con distance), si esta muy
%       lejos querra decir que es un nuevo coche.
%       b) Las medidas que se hagan deben superar un threshold  (por
%       ejemplo fillratio de puntos segmentados) si este es muy pequeño no
%       se considera medida. Si pasa el suficiente tiempo (X frames), se
%       supondra que el coche ha desaparecido y ya no hace falta seguirlo
%       O del mismo modo que si la estimación hace que se salga de los
%       rangos de la imagen.
limits = [0, sizeIm(2); 0, sizeIm(1)];
maxDistanceMeasurement = 20;
minDistanceMerge = 20;
mergePenalize = 16;
maxLive = 10;
stepLive = 1;
timeThres = 16;
timeStopThres = 15;
fps = 30;
trackers = TrackingObjectsSDA(limits, maxDistanceMeasurement, minDistanceMerge, mergePenalize, maxLive, stepLive, timeThres, timeStopThres, velocityEstimator(1), fps);

for iSeq = 1:length(inputFolders),
    % Set velocityEstimation for each sequence
    trackers.setVelocityEstimator(velocityEstimator(iSeq));
    
    for id=idSequenceDemo{iSeq}           
            imName = sprintf('%06d', id);
            fileName = [inputFolders{iSeq}, imName, fileFormat];
            % Si esta activada aplicamos la tform a cada imagen
            im = imread(fileName);

            % obtenemos la mascara
            mask = detector{iSeq}.detectForeground(im);
            mask = morphoObjDetectionFunction(mask);
            %imshow(mask);
            %pause(0.0001);
            
            % Aplicamos el pipeline
            trackers.checkMeasurements(mask, im);
            
            positions = trackers.getTrackers(im, homographySeq{iSeq});
            trackers.showTrackers(im, mask, positions);
            
    end
    
end