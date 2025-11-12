% ===================================================================
% SCRIPT: Etapa4_entrenar_cnn.m
% OBJETIVO: Entrenar una Red Neuronal Convolucional (CNN)
%           usando imageDatastore.
% ===================================================================

function [net, accuracy] = Etapa4_entrenar_cnn(datos_path)

    fprintf('--- Iniciando Etapa 4: Entrenamiento de CNN ---\n');

    % 1. Verificar la ruta de los datos
    if ~exist(datos_path, 'dir')
        error('La carpeta de datos (%s) no existe. Asegúrate de seguir el README.', datos_path);
    end

    % 2. Cargar datos usando imageDatastore
    % imageDatastore etiqueta automáticamente las imágenes
    % basándose en la estructura de carpetas (Clase_0, Clase_1).
    imds = imageDatastore(datos_path, ...
        'IncludeSubfolders', true, ...
        'LabelSource', 'foldernames');

    fprintf('Total de imágenes cargadas: %d\n', numel(imds.Files));
    fprintf('Clases encontradas: %s\n', strjoin(categories(imds.Labels), ', '));

    % 3. Dividir datos (Entrenamiento y Validación)
    % Asumiendo que 'datos_path' apunta a la carpeta 'Entrenamiento'
    % Para un proyecto real, se dividiría en train/validation
    % Aquí usaremos todos los datos de 'datos_path' para entrenar
    % y luego el usuario cargará por separado la carpeta 'Prueba'

    % Opcional: Dividir el 'imds' de Entrenamiento en train/validation
    [imdsTrain, imdsValidation] = splitEachLabel(imds, 0.8, 'randomized');

    fprintf('Imágenes de entrenamiento: %d\n', numel(imdsTrain.Files));
    fprintf('Imágenes de validación: %d\n', numel(imdsValidation.Files));

    % 4. Definir la Arquitectura de la CNN
    % (Basado en el Anexo 4)

    % Definir tamaño de entrada estándar
    inputSize = [64 64 1]; % 64x64 píxeles, escala de grises (1 canal)

    % Crear datastores aumentados para redimensionar imágenes
    augimdsTrain = augmentedImageDatastore(inputSize, imdsTrain, 'ColorPreprocessing', 'rgb2gray');
    augimdsValidation = augmentedImageDatastore(inputSize, imdsValidation, 'ColorPreprocessing', 'rgb2gray');

    numClasses = numel(categories(imdsTrain.Labels));
    fprintf('Número de clases: %d\n', numClasses);

    % Definir la arquitectura de la CNN
    layers = [
        imageInputLayer(inputSize, 'Name', 'input')

        convolution2dLayer(3, 8, 'Padding', 'same', 'Name', 'conv1')
        batchNormalizationLayer('Name', 'bn1')
        reluLayer('Name', 'relu1')

        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'maxpool1')

        convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'conv2')
        batchNormalizationLayer('Name', 'bn2')
        reluLayer('Name', 'relu2')

        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'maxpool2')

        convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv3')
        batchNormalizationLayer('Name', 'bn3')
        reluLayer('Name', 'relu3')

        fullyConnectedLayer(numClasses, 'Name', 'fc')
        softmaxLayer('Name', 'softmax')
        classificationLayer('Name', 'output')];

    fprintf('Arquitectura de CNN definida.\n');

    % 5. Opciones de Entrenamiento
    options = trainingOptions('sgdm', ...
        'InitialLearnRate', 0.01, ...
        'MaxEpochs', 10, ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', augimdsValidation, ...
        'ValidationFrequency', 5, ...
        'Verbose', false, ...
        'Plots', 'training-progress');

    % 6. Entrenar la Red
    fprintf('Entrenando la CNN... Esto puede tardar unos minutos.\n');
    net = trainNetwork(augimdsTrain, layers, options);

    % 7. Evaluar en Validación
    YPred = classify(net, augimdsValidation);
    YValidation = imdsValidation.Labels;
    accuracy = sum(YPred == YValidation) / numel(YValidation);

    fprintf('Entrenamiento de CNN completado.\n');
    fprintf('Precisión en el set de Validación: %.2f%%\n', accuracy * 100);

    % 8. Mostrar Matriz de Confusión
    figure;
    confusionchart(YValidation, YPred);
    title('Matriz de Confusión (Validación)');

    % 9. Guardar el modelo
    save('cnn_model_etapa4.mat', 'net');
    fprintf('Modelo CNN guardado en cnn_model_etapa4.mat\n');

end
