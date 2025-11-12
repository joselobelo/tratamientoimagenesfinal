% ==========================================================
% SCRIPT: procesar_y_clasificar.m (v3 - Flujo Corregido)
% TAREA:  Automatización Etapa 3 - Extracción, SVM y Umbral
% ==========================================================
% Nombre:   LUIS FERNANDO OROZCO ARENAS
% Cédula:   1062814259
% Grupo:    208054_4
% Tutora:   SANDRA MILENA GARCIA
% Periodo:  2024 I PERIODO 16-01 (1701)
% ==========================================================

%% % --- CONFIGURACIÓN INICIAL ---
clear all; clc; close all;
fprintf('--- INICIANDO PROCESAMIENTO ETAPA 3 (Flujo Corregido) ---\n');

% --- Parámetros de Procesamiento (Ajustar según Etapa 2) ---
umbral_binarizacion = 0.7;
numpixels_filtro = 20;

% --- Carpetas y Archivos ---
carpetaEntrenamiento = 'Entrenamiento';
carpetaPrueba = 'Prueba';
archivoEntrenamientoFeatures = 'entrenamiento_features.xlsx'; % Solo características
archivoPruebaFeatures = 'prueba_features.xlsx';           % Solo características
archivoEntrenamientoLabeled = 'entrenamiento_LABELED.xlsx'; % Con etiquetas manuales
archivoPruebaLabeled = 'prueba_LABELED.xlsx';           % Con etiquetas manuales
archivoUmbralEntrada = 'datos_umbral_entrada.xlsx';     % Para datos del clasificador umbral
archivoResultadosSVM = 'resultados_svm.xlsx';
archivoResultadosUmbral = 'resultados_umbral.xlsx';

% --- Parámetros Clasificador Umbral (¡AJUSTAR ESTOS!) ---
umbralCentroideY_usuario = 11.0;
umbralCircularidad_usuario = 0.5;
% Lógica Umbral: Ajusta la condición 'if' abajo en PASO 4

%% % --- PASO 1: EXTRACCIÓN CARACTERÍSTICAS (ENTRENAMIENTO) ---
% Ejecuta esta sección primero
fprintf('\n--- PASO 1: Extrayendo características de %s ---\n', carpetaEntrenamiento);
try
    tablaEntrenamientoFeatures = extraerCaracteristicasCarpeta(carpetaEntrenamiento, umbral_binarizacion, numpixels_filtro);
    writetable(tablaEntrenamientoFeatures, archivoEntrenamientoFeatures);
    fprintf('   ✅ Características de Entrenamiento guardadas en %s\n', archivoEntrenamientoFeatures);
catch ME
    error('   ❌ FALLO en extracción (Entrenamiento): %s\n', ME.message);
end

%% % --- PASO 2: EXTRACCIÓN CARACTERÍSTICAS (PRUEBA) ---
% Ejecuta esta sección junto con la anterior
fprintf('\n--- PASO 2: Extrayendo características de %s ---\n', carpetaPrueba);
try
    tablaPruebaFeatures = extraerCaracteristicasCarpeta(carpetaPrueba, umbral_binarizacion, numpixels_filtro);
    writetable(tablaPruebaFeatures, archivoPruebaFeatures);
    fprintf('   ✅ Características de Prueba guardadas en %s\n', archivoPruebaFeatures);
catch ME
    error('   ❌ FALLO en extracción (Prueba): %s\n', ME.message);
end

fprintf('\n--- PASO 1 y 2 COMPLETADOS ---');
fprintf('\n>>> AHORA DEBES ABRIR %s y %s, AÑADIR MANUALMENTE LA COLUMNA ''ClasificacionExperto'' (1=ELECTRICO, 0=NO ELECTRICO) Y GUARDARLOS COMO %s y %s <<<\n', ...
    archivoEntrenamientoFeatures, archivoPruebaFeatures, archivoEntrenamientoLabeled, archivoPruebaLabeled);
fprintf('>>> DESPUÉS DE GUARDARLOS, EJECUTA LAS SIGUIENTES SECCIONES (PASO 3 Y 4) <<<\n');

% --- DETENER EJECUCIÓN AQUÍ LA PRIMERA VEZ ---
% return; % Descomenta 'return;' si quieres que el script pare aquí automáticamente

%% % --- PASO 3: ENTRENAMIENTO Y CLASIFICACIÓN SVM ---
% Ejecuta esta sección DESPUÉS de haber creado los archivos _LABELED.xlsx
fprintf('\n--- PASO 3: Entrenando y clasificando con SVM (Usando archivos etiquetados) ---\n');
try
    % Verificar si existen los archivos etiquetados
    if ~isfile(archivoEntrenamientoLabeled) || ~isfile(archivoPruebaLabeled)
        error('No se encontraron los archivos %s o %s. Asegúrate de crearlos y etiquetarlos manualmente.', ...
               archivoEntrenamientoLabeled, archivoPruebaLabeled);
    end

    % Cargar datos ETIQUETADOS
    datosEntrenamiento = readtable(archivoEntrenamientoLabeled);
    datosPrueba = readtable(archivoPruebaLabeled);

    % Preparar datos para fitcsvm
    caracteristicasEnt = datosEntrenamiento{:, {'CentroideX', 'CentroideY', 'Circularidad'}};
    etiquetasEnt = datosEntrenamiento.ClasificacionExperto; % ¡Usa las etiquetas correctas!
    caracteristicasPrueba = datosPrueba{:, {'CentroideX', 'CentroideY', 'Circularidad'}};

    % Entrenar SVM
    svmModel = fitcsvm(caracteristicasEnt, etiquetasEnt, 'Standardize', true, 'KernelFunction', 'linear', 'KernelScale', 'auto');

    % Predecir en datos de prueba
    prediccionesSVM = predict(svmModel, caracteristicasPrueba);

    % Guardar resultados SVM
    tablaResultadosSVM = datosPrueba(:, {'Imagen', 'ClasificacionExperto'});
    tablaResultadosSVM.PrediccionSVM = prediccionesSVM;
    writetable(tablaResultadosSVM, archivoResultadosSVM);
    fprintf('   ✅ Predicciones SVM guardadas en %s\n', archivoResultadosSVM);
    disp('   Predicciones SVM:');
    disp(prediccionesSVM);
catch ME
    error('   ❌ FALLO en SVM: %s\n', ME.message);
end

%% % --- PASO 4: CLASIFICADOR POR UMBRAL ---
% Ejecuta esta sección junto con la anterior
fprintf('\n--- PASO 4: Aplicando Clasificador por Umbral (Usando archivos etiquetados) ---\n');
try
    % Usar datos ya cargados de la tabla de prueba ETIQUETADA
    if ~exist('datosPrueba', 'var') % Si no se ejecutó la sección 3
         if ~isfile(archivoPruebaLabeled)
             error('No se encontró el archivo %s.', archivoPruebaLabeled);
         end
         datosPrueba = readtable(archivoPruebaLabeled);
    end

    centroideY_prueba = datosPrueba.CentroideY;
    circularidad_prueba = datosPrueba.Circularidad;
    etiquetasReales_prueba = datosPrueba.ClasificacionExperto; % ¡Usa las etiquetas correctas!

    % Crear tabla de entrada para umbral
    tablaUmbralEntrada = datosPrueba(:,{'Imagen','CentroideY','Circularidad','ClasificacionExperto'});
    writetable(tablaUmbralEntrada, archivoUmbralEntrada);
    fprintf('   ℹ️  Datos de entrada para umbral guardados en %s\n', archivoUmbralEntrada);

    % Clasificar con umbrales definidos por el usuario
    prediccionesUmbral = zeros(height(datosPrueba), 1);
    for i = 1:height(datosPrueba)
        % --- ¡¡¡ AJUSTA ESTA LÓGICA !!! ---
        if centroideY_prueba(i) < umbralCentroideY_usuario && circularidad_prueba(i) > umbralCircularidad_usuario
            prediccionesUmbral(i) = 1; % Clase 1
        else
            prediccionesUmbral(i) = 0; % Clase 0
        end
        % --- FIN LÓGICA AJUSTABLE ---
    end

    % Calcular precisión usando las etiquetas REALES
    correctosUmbral = sum(prediccionesUmbral == etiquetasReales_prueba);
    precisionUmbral = (correctosUmbral / height(datosPrueba)) * 100;
    fprintf('   🎯 Precisión del Clasificador Umbral: %.2f%%\n', precisionUmbral);

    % Guardar resultados Umbral
    tablaResultadosUmbral = datosPrueba(:, {'Imagen', 'ClasificacionExperto'});
    tablaResultadosUmbral.PrediccionUmbral = prediccionesUmbral;
    writetable(tablaResultadosUmbral, archivoResultadosUmbral);
    fprintf('   ✅ Predicciones Umbral guardadas en %s\n', archivoResultadosUmbral);
    disp('   Comparación Real vs. Umbral:');
    disp([etiquetasReales_prueba, prediccionesUmbral]);

catch ME
    error('   ❌ FALLO en Clasificador Umbral: %s\n', ME.message);
end

fprintf('\n--- PROCESAMIENTO COMPLETO FINALIZADO ---\n');

%% % --- FUNCIÓN AUXILIAR PARA EXTRACCIÓN (SIN ETIQUETA EXPERTO AUTOMÁTICA) ---
function tabla = extraerCaracteristicasCarpeta(carpeta, umbral, numpix)
    listaArchivos = dir(fullfile(carpeta, '*.jpg')); % Busca .jpg
    numImagenes = length(listaArchivos);

    % Preparar tabla (SIN ClasificacionExperto)
    nombresVariables = {'Imagen', 'CentroideX', 'CentroideY', 'Circularidad'};
    tabla = table('Size', [numImagenes, length(nombresVariables)], ...
                  'VariableTypes', {'string', 'double', 'double', 'double'}, ...
                  'VariableNames', nombresVariables);

    for i = 1:numImagenes
        nombreArchivo = listaArchivos(i).name;
        rutaCompleta = fullfile(carpeta, nombreArchivo);
        fprintf('      Procesando %s...\n', nombreArchivo);

        try
            ID = imread(rutaCompleta);
            if size(ID,3) == 3
               GrayID = rgb2gray(ID);
            else
               GrayID = ID;
            end
            GrayID = im2double(GrayID);

            binID = imbinarize(GrayID, umbral);
             if mean(binID(:)) > 0.5
                binID = ~binID;
                % disp('      (Imagen posiblemente invertida, negando...)');
            end

            Filtro1 = bwareaopen(binID, numpix);
            [Lo, num] = bwlabel(Filtro1);

            if num > 0
                prop = regionprops(Lo, 'BoundingBox', 'Area');
                [~, idxObjetoPrincipal] = max([prop.Area]);

                objeto_img = imcrop(Filtro1, prop(idxObjetoPrincipal).BoundingBox);
                prop_objeto = regionprops(objeto_img, 'Centroid', 'Circularity');

                if ~isempty(prop_objeto)
                    centroide = prop_objeto(1).Centroid;
                    circularidad = prop_objeto(1).Circularity;

                    % Guardar solo características
                    tabla.Imagen(i) = string(nombreArchivo);
                    tabla.CentroideX(i) = centroide(1);
                    tabla.CentroideY(i) = centroide(2);
                    tabla.Circularidad(i) = circularidad;
                else
                     warning('      Objeto recortado sin propiedades: %s', nombreArchivo);
                     tabla(i,:) = {string(nombreArchivo), NaN, NaN, NaN}; % Llenar con NaN
                end
            else
                warning('      No se encontraron objetos en %s', nombreArchivo);
                tabla(i,:) = {string(nombreArchivo), NaN, NaN, NaN}; % Llenar con NaN
            end
        catch ME
            warning('      ERROR procesando %s: %s', nombreArchivo, ME.message);
            tabla(i,:) = {string(nombreArchivo) + " (ERROR)", NaN, NaN, NaN}; % Marcar error
        end
    end
     % Eliminar filas que fallaron completamente (NaN en CentroideX)
     tabla = rmmissing(tabla, 'DataVariables', 'CentroideX');
end

