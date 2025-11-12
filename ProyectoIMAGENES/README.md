# 🤖 Proyecto de Tratamiento de Imágenes (UNAD 208054) - Etapa 3 y 4

Este repositorio contiene la implementación de clasificadores de imágenes (SVM y CNN) para el curso de Tratamiento de Imágenes, corrigiendo los errores de la Etapa 3 e implementando la solución de la Etapa 4.

## 🚀 Estructura del Repositorio

* `/Informe_Proyecto_UNAD.ipynb`: El informe principal y orquestador que genera estos scripts.
* `/scripts_matlab/`: Contiene todos los scripts de MATLAB.
    * `Etapa3_corregida_extraccion.m`: Script que corrige la extracción de características de la Etapa 3 (usa QR, no max-area) y auto-etiqueta los datos.
    * `Etapa3_corregida_entrenar_svm.m`: Entrena el modelo SVM clásico usando los datos corregidos.
    * `Etapa4_entrenar_cnn.m`: Script principal que entrena la Red Neuronal Convolucional (CNN).
* `/datos/`: Carpeta que **debe ser creada manualmente** por el usuario.

## ⚙️ Instrucciones de Ejecución

### Paso 1: Configurar la Carpeta `datos`

**Este es el paso más importante.** Para que los scripts funcionen, debe crear la carpeta `datos` y organizar las imágenes de `Entrenamiento` y `Prueba` (proporcionadas por el tutor) de la siguiente manera:

```
/PROYECTO_TRATAMIENTO_IMAGENES_UNAD/
│
└── 🖼️ datos/
    │
    ├── 📁 Entrenamiento/
    │   ├── 📁 Clase_0/
    │   │   (Pega aquí las imágenes 1, 3, 5, 7, 9, 11, 13, 15, 17, 19)
    │   │
    │   └── 📁 Clase_1/
    │       (Pega aquí las imágenes 2, 4, 6, 8, 10, 12, 14, 16, 18, 20)
    │
    └── 📁 Prueba/
        ├── 📁 Clase_0/
        │   (Pega aquí las imágenes de prueba No Eléctricas)
        │
        └── 📁 Clase_1/
            (Pega aquí las imágenes de prueba Eléctricas)
```

### Paso 2: Ejecutar el Proyecto

1.  **Abrir `Informe_Proyecto_UNAD.ipynb`:** Este notebook es el informe completo.
2.  **Ejecutar las celdas:**
    * Las celdas `%%writefile` generarán los scripts `.m`.
    * Las celdas de MATLAB (requieren un kernel de MATLAB en Jupyter) ejecutarán los scripts.
3.  **Alternativamente (Recomendado):**
    * Abre MATLAB.
    * Navega a la carpeta `/scripts_matlab/`.
    * Ejecuta `Etapa4_entrenar_cnn('./datos/Entrenamiento')` desde la ventana de comandos de MATLAB para entrenar y evaluar el modelo final de la Etapa 4.

## 📋 Mapa de Clases

El etiquetado automático de las imágenes se basa en el número en el nombre del archivo:

* **Clase 1 (Eléctrico):** Imágenes 2, 4, 6, 8, 10, 12, 14, 16, 18, 20
* **Clase 0 (No Eléctrico):** Imágenes 1, 3, 5, 7, 9, 11, 13, 15, 17, 19

## 🔧 Requisitos

* MATLAB R2019a o superior
* Image Processing Toolbox
* Deep Learning Toolbox
* Statistics and Machine Learning Toolbox

## 📚 Correcciones de la Etapa 3

Este proyecto corrige dos errores críticos identificados en la retroalimentación de la Etapa 3:

1. **Error de Extracción:** Se cambió de `max([prop.Area])` a `prop(end).BoundingBox` para extraer el QR/ID correcto
2. **Error de Etiquetado:** Se automatizó el etiquetado usando el nombre del archivo, eliminando etiquetas inconsistentes

## 📊 Resultados Esperados

* **Etapa 3 Corregida (SVM):** Baseline comparativo con características morfológicas
* **Etapa 4 (CNN):** Modelo de Deep Learning con > 90% de precisión esperada

## 👨‍🎓 Autor

**Curso:** Tratamiento de Imágenes (208054)
**Universidad:** UNAD (Universidad Nacional Abierta y a Distancia)
**Tutora:** Sandra García
