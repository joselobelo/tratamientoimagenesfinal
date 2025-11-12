% ===================================================================
% SCRIPT: Etapa3_corregida_entrenar_svm.m
% OBJETIVO: Entrena el SVM de la Etapa 3 usando los datos CORREGIDOS.
% ===================================================================

function [svmModel, accuracy] = Etapa3_corregida_entrenar_svm(features_file)

    fprintf('Entrenando SVM con datos corregidos de: %s\n', features_file);

    % Cargar datos corregidos
    if ~exist(features_file, 'file')
        error('Archivo de features no encontrado. Ejecuta Etapa3_corregida_extraccion.m primero.');
    end
    data = readtable(features_file);

    % Preparar datos
    X = data{:, {'CentroideX', 'CentroideY', 'Circularidad'}};
    Y = data.ClasificacionExperto;

    % Entrenar SVM (Kernel Lineal como en la guía)
    svmModel = fitcsvm(X, Y, 'Standardize', true, 'KernelFunction', 'linear', 'KernelScale', 'auto');

    % Guardar el modelo
    save('svmModel_corregido.mat', 'svmModel');

    % Validar rendimiento (Cross-Validation)
    CVSVM = crossval(svmModel);
    accuracy = 1 - kfoldLoss(CVSVM);

    fprintf('Modelo SVM corregido entrenado y guardado en svmModel_corregido.mat\n');
    fprintf('Precisión (Cross-Validation) del modelo SVM corregido: %.2f%%\n', accuracy * 100);

end
