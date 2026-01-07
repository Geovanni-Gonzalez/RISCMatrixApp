# Manual de Usuario - RISCMatrixApp

## Interacción

El programa se ejecuta en consola y presenta un menú numérico. El usuario debe ingresar el número correspondiente a la opción deseada y presionar Enter.

### Menú Principal

1. **Crear Matrices**:
   - Seleccione A o B.
   - Elija modo: 1 (Automático) o 2 (Manual).
   - Ingrese Filas y Columnas (2-20).
   - *Nota*: En modo manual, ingrese valores uno a uno seguidos de Enter.

2. **Suma de Matrices**:
   - Muestra el resultado de A + B.
   - Requiere que A y B tengan las mismas dimensiones.

3. **Multiplicación de Matrices**:
   - Muestra el resultado de A * B.
   - Número de Columnas de A debe ser igual a Filas de B.

4. **Rotación de Matrices**:
   - Seleccione A o B.
   - Ingrese el ángulo (90, 180, 270...).
   - La matriz será rota 90 grados en sentido horario (actualmente simplificado a un paso por operación).

5. **Submatriz de Suma Máxima**:
   - Calcula internamente la subregión con mayor suma de elementos.

6. **Mostrar Matrices**:
   - Imprime en pantalla el estado actual de A y B.

7. **Salir**:
   - Cierra la aplicación de forma segura.

## Solución de Problemas

- **Dimensiones Incompatibles**: Asegúrese de crear las matrices con las dimensiones correctas antes de operar.
- **Entrada Inválida**: Si ingresa caracteres no numéricos donde se esperan números, el comportamiento es indefinido (validación básica implementada).
