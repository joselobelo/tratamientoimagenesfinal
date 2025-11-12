% ===================================================================
% SCRIPT: Etapa3_corregida_extraccion.m
% OBJETIVO: Corrige el error de la Etapa 3.
%   1. Extracción: Usa prop(end) para obtener el QR/ID (el ÚLTIMO objeto).
%   2. Auto-Etiquetado: Deduce la clase (1 o 0) desde el nombre del archivo.
% ===================================================================

function T = Etapa3_corregida_extraccion(carpeta)

    fprintf('Iniciando extracción corregida en: %s\n', carpeta);

    % Parámetros (ajustar si es necesario)
    umbral_binarizacion = 0.7;
    numpixels_filtro = 20;

    % Clases (Eléctrico = 1, No Eléctrico = 0)
    clase_1_files = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20];
    clase_0_files = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19];

    % Listar todas las imágenes
    img_files = dir(fullfile(carpeta, '*.jpg'));

    % Pre-alocar la tabla de resultados
    T = table('Size', [length(img_files), 5], ...
              'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ...
              'VariableNames', {'Imagen', 'CentroideX', 'CentroideY', 'Circularidad', 'ClasificacionExperto'});

    for i = 1:length(img_files)
        nombre_archivo = img_files(i).name;
        ruta_completa = fullfile(carpeta, nombre_archivo);

        try
            % --- Procesamiento de Imagen ---
            I = imread(ruta_completa);
            if size(I, 3) == 3
                I_gray = rgb2gray(I);
            else
                I_gray = I;
            end

            I_bin = imbinarize(I_gray, umbral_binarizacion);

            % Corregir inversión (si el fondo es blanco)
            if mean(I_bin(:)) > 0.5
                I_bin = ~I_bin;
            end

            I_filt = bwareaopen(I_bin, numpixels_filtro);

            % --- Extracción de Características (LA CORRECCIÓN) ---
            [L, num] = bwlabel(I_filt);

            if num > 0
                % prop(end) selecciona el ÚLTIMO objeto etiquetado,
                % asumiendo que el QR/ID es el último en ser escaneado.
                % ESTA ES LA CORRECCIÓN DEL FEEDBACK.
                prop = regionprops(L, 'BoundingBox', 'Centroid', 'Circularity');

                % Recortar solo el último objeto
                qr_img = imcrop(I_filt, prop(end).BoundingBox);

                % Medir propiedades SOLO del objeto recortado (el QR)
                prop_qr = regionprops(qr_img, 'Centroid', 'Circularity');

                if ~isempty(prop_qr)
                    centroide = prop_qr(1).Centroid;
                    circularidad = prop_qr(1).Circularity;

                    T.Imagen(i) = string(nombre_archivo);
                    T.CentroideX(i) = centroide(1);
                    T.CentroideY(i) = centroide(2);
                    T.Circularidad(i) = circularidad;
                else
                    error('No se encontraron propiedades en el objeto recortado.');
                end
            else
                error('bwlabel no encontró objetos.');
            end

            % --- Auto-Etiquetado (CORRECCIÓN 2) ---
            % Extraer el número del nombre del archivo (ej. '1.jpg', '10.jpg')
            [~, name, ~] = fileparts(nombre_archivo);
            num_archivo = str2double(name);

            if ismember(num_archivo, clase_1_files)
                T.ClasificacionExperto(i) = 1; % Eléctrico
            elseif ismember(num_archivo, clase_0_files)
                T.ClasificacionExperto(i) = 0; % No Eléctrico
            else
                T.ClasificacionExperto(i) = NaN; % No clasificado
            end

            fprintf('Procesado (CORREGIDO): %s -> Clase %d\n', nombre_archivo, T.ClasificacionExperto(i));

        catch ME
            fprintf('ERROR al procesar %s: %s\n', nombre_archivo, ME.message);
            T.Imagen(i) = string(nombre_archivo);
            T.ClasificacionExperto(i) = NaN;
        end
    end

    % Limpiar filas con errores
    T = T(~isnan(T.ClasificacionExperto), :);
    writetable(T, 'etapa3_features_corregidas.xlsx');
    fprintf('Extracción corregida completada. Resultados guardados en etapa3_features_corregidas.xlsx\n');
end
