# RISCMatrixApp - Operaciones con Matrices en ARM Assembly

**Curso:** Arquitectura de Computadores
**Proyecto:** 02 - Operaciones con Matrices (RISC)
**Plataforma:** Raspberry Pi (ARMv7) / QEMU (Raspbian)

## Descripción

Programa de consola desarrollado en lenguaje ensamblador puro (utilizando solo `as` y `ld`) que permite la manipulación de matrices dinámicas. El sistema gestiona la memoria manualmente mediante llamadas al sistema (syscalls) para ofrecer funcionalidades de creación, aritmética y análisis de matrices.

## Estructura del Proyecto

- `src/`: Código fuente (.s)
  - `main.s`: Lógica principal y manejo de menús.
  - `matrix.s`: Lógica de operaciones matriciales (Suma, Multiplicación, Rotación).
  - `memory.s`: Gestor de memoria dinámica (`malloc` personalizado usando `brk`).
  - `utils.s`: Utilidades de Entrada/Salida (Conversiones ASCII-Entero, Impresión de cadenas).
  - `macros.s`: Definiciones de macros y constantes del sistema.
- `Makefile`: Script de compilación y enlazado.

## Requerimientos Previos

- Sistema Operativo Linux (Raspbian recomendado).
- Herramientas GNU Binutils (`as`, `ld`).
- Arquitectura ARM (via hardware real o emulación QEMU).

## Compilación y Ejecución

Para compilar el proyecto, navegue a la carpeta raíz y ejecute:

```bash
make
```

Esto generará el ejecutable `matrix_app`. Para correrlo:

```bash
./matrix_app
```

Para limpiar los archivos objeto:

```bash
make clean
```

## Funcionalidades

1. **Crear Matrices**: Generación manual (0-255) o automática (0-1023).
2. **Suma**: Suma de Matriz A y Matriz B.
3. **Multiplicación**: Producto matricial A x B.
4. **Rotación**: Rotación de 90° en sentido horario (Matrices cuadradas).
5. **Submatriz Máxima**: Cálculo de la submatriz con mayor suma.
6. **Mostrar**: Visualización de las matrices actuales.

## Notas de Desarrollo

- Se utiliza el syscall `brk` (45) para la gestión del Heap.
- No se utilizan librerías estándar de C (libc). Todo el IO es mediante `sys_read` y `sys_write`.
- Se implementó un generador de números pseudoaleatorios (LCG) para el llenado automático.
