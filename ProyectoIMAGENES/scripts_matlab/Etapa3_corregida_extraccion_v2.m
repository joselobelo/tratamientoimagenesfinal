% ===================================================================
% SCRIPT: Etapa3_corregida_extraccion_v2.m
% OBJETIVO: Corrige el script de Etapa 3 para leer en subcarpetas
%           (Clase_0, Clase_1), igual que la Etapa 4.
% ===================================================================

function T = Etapa3_corregida_extraccion_v2(carpeta_principal)
    
    fprintf('Iniciando extracción v2 en: %s\n', carpeta_principal);
    
    % Parámetros
    umbral_binarizacion = 0.7;
    numpixels_filtro = 20;

    % Buscar imágenes en las subcarpetas (Clase_0 y Clase_1)
    imds = imageDatastore(carpeta_principal, ...
        'IncludeSubfolders', true, ...
        'LabelSource', 'foldernames');
    
    num_imagenes = numel(imds.Files);
    if num_imagenes == 0
        error('No se encontraron imágenes en %s. Asegúrate de que las carpetas Clase_0 y Clase_1 existan.', carpeta_principal);
    end
    
    % Pre-alocar la tabla
    T = table('Size', [num_imagenes, 5], ...
              'VariableTypes', {'string', 'string', 'double', 'double', 'double'}, ...
              'VariableNames', {'Imagen', 'Clase', 'CentroideX', 'CentroideY', 'Circularidad'});

    for i = 1:num_imagenes
        ruta_completa = imds.Files{i};
        [~, nombre_archivo, ext] = fileparts(ruta_completa);
        nombre_completo = [nombre_archivo, ext];
        
        % La etiqueta la da la carpeta
        etiqueta = imds.Labels(i);
        
        try
            % --- Procesamiento de Imagen (igual que antes) ---
            I = imread(ruta_completa);
            if size(I, 3) == 3
                I_gray = rgb2gray(I);
            else
                I_gray = I;
            end
            
            I_bin = imbinarize(I_gray, umbral_binarizacion);
            if mean(I_bin(:)) > 0.5
                I_bin = ~I_bin;
            end
            I_filt = bwareaopen(I_bin, numpixels_filtro);
            
            % --- Extracción (Lógica del QR corregida) ---
            [L, num] = bwlabel(I_filt);
            if num > 0
                prop = regionprops(L, 'BoundingBox');
                qr_img = imcrop(I_filt, prop(end).BoundingBox);
                prop_qr = regionprops(qr_img, 'Centroid', 'Circularity');
                
                if ~isempty(prop_qr)
                    centroide = prop_qr(1).Centroid;
                    circularidad = prop_qr(1).Circularity;
                    
                    % Llenar la tabla
                    T.Imagen(i) = string(nombre_completo);
                    T.Clase(i) = string(etiqueta);
                    T.CentroideX(i) = centroide(1);
                    T.CentroideY(i) = centroide(2);
                    T.Circularidad(i) = circularidad;
                else
                    error('No se encontraron propiedades en el objeto recortado.');
                end
            else
                error('bwlabel no encontró objetos.');
            end
        catch ME
            fprintf('ERROR al procesar %s: %s\n', nombre_completo, ME.message);
            T.Imagen(i) = string(nombre_completo);
            T.Clase(i) = "Error";
        end
    end
    
    % Limpiar filas con errores
    T = T(T.Clase ~= "Error", :);
    fprintf('Extracción v2 completada. Se procesaron %d imágenes.\n', height(T));
end