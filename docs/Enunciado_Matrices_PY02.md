

Código: PY02
Nombre del Proyecto: Operaciones con Matrices en Arquitectura RISC
Modalidad: Programa en Consola
Lenguaje: Ensamblador para Arquitectura RISC
Sistema Operativo: Raspbian OS (Raspberry Pi o emulador QEMU)

## Objetivo General
Desarrollar un programa en consola que permita crear matrices y realizar operaciones sobre
las mismas por medio de programación a bajo nivel en una arquitectura RISC.

## Objetivos Específicos
 Aprender sobre el desarrollo de programas mediante programación a bajo nivel.
 Comprender el uso de la memoria a diferentes niveles de programación.
 Fomentar la utilización de memoria dinámica para brindar flexibilidad a los
programas.
 Estimular el pensamiento lógico mediante resolución de algoritmos y manejo de
punteros.

## Requerimientos Funcionales
La interacción con el programa será completamente por consola. Se debe validar todas las
entradas del usuario para garantizar la robustez del software. El menú principal incluirá las
siguientes opciones:
## 1. Crear Matrices
Permite generar dos matrices independientes (dimensiones entre 2×2 y 20×20, no
necesariamente cuadradas).
Opciones de carga de valores:
 Generador automático: valores aleatorios entre 0 y 1023.
 Ingreso manual: valores numéricos entre 0 y 255 ingresados por el usuario.
- Suma de Matrices
Valida si las dimensiones permiten la operación. Muestra ambas matrices y el resultado.
- Multiplicación de Matrices

Verifica si es posible multiplicar A×B, B×A o ambas. Muestra operandos y resultados según el
caso.
- Rotación de Matrices
Solo disponible para matrices cuadradas. El usuario debe indicar un ángulo múltiplo de 90°
(sentido horario). En caso de entrada inválida, se solicita una nueva.
- Submatriz de Suma Máxima
Permite obtener el valor de la suma más alta posible entre todas las submatrices válidas de
una matriz seleccionada.
## 6. Mostrar Matrices
Presenta ambas matrices de manera clara y organizada en consola. Se valorará la
presentación visual.

## Tecnología
 Lenguaje: Ensamblador para arquitectura RISC
 Plataforma: Raspberry Pi o emulador QEMU con Raspbian OS
 Compiladores: Herramientas as y ld (exclusivamente)
 Restricciones: No se permite uso de C/C++, solo llamadas al sistema operativo

Grupos de Trabajo
 Integrantes: Grupos de 2 o 3 estudiantes
 No se aceptan grupos con distinta cantidad sin justificación y aprobación previa
 Los estudiantes sin grupo serán asignados aleatoriamente

## Datos Administrativos
 Valor: 15% del curso
 Fecha de entrega: Jueves 28 de septiembre, 5:00 PM (hora del servidor)
 Penalización por entrega tardía: 2 puntos por día de retraso
Entrega mediante enlace a un repositorio compartido o público. Solo se evaluarán los
commits anteriores a la fecha límite, a menos que se notifique evaluación tardía.

Canal de Comunicación

Las consultas deben realizarse a través del Foro Proyecto 02, abierto para resolver y discutir
dudas durante toda la duración del proyecto.

Criterios de Evaluación
Se aplicará la rúbrica oficial publicada en el curso.
Se valorará especialmente:
 Estandarización del código (según documento adjunto)
 Claridad y autonomía del programa y documentación
 Presentación ordenada y detallada del repositorio y funcionalidad

## Recomendaciones Finales
"Empiecen con tiempo suficiente, analicen y diseñen la solución. La programación debe
iniciarse solo cuando se tenga completo dominio del problema; así, cada línea de código
tendrá propósito y claridad hacia el objetivo final."
¡Mucho éxito con el proyecto!
