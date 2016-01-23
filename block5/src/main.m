%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 5 of the
% project.
% 

%% Setup
setup;

%% Config
enable_homography = true;

%% Morpho to detect objects
morphoFunction = @detectionMorpho;

%% Learn foreground estimator and apply homography
% Primero aprendemos el modelo para estimar que son coches y que no.
learnDetector;


%% Read the rest of the sequence
idSequenceDemo = {1:1700 - setdiff(idSequenceLearn{1}); 1:1570 - setdiff(idSequenceLearn{2})};

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
