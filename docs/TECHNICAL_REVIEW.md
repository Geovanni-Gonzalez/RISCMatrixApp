# TECHNICAL_REVIEW — RISCMatrixApp

Fecha de revisión: 2026-07-16
Método: análisis estático del ensamblador, enunciado (`docs/Enunciado_Matrices_PY02.md`), Makefile, CI y git. Sin ejecución en esta pasada; CI compila con toolchain ARM real (build-only).

## 1. Comprensión del proyecto

Aplicación de consola de operaciones con matrices en ensamblador ARM (~1,260 líneas, 5 módulos + macros), objetivo Raspberry Pi/QEMU, sin C (restricción del enunciado: solo `as`/`ld` y syscalls). Complementa a `BattleshipARM` como evidencia de bajo nivel; su diferenciador es la **gestión de memoria dinámica propia** y la carga algorítmica.

## 2. Cumplimiento del enunciado

| Requisito | Estado | Evidencia |
|---|---|---|
| Crear 2 matrices, 2×2-20×20, no necesariamente cuadradas | 🟦 | `matrix.s` → `create_matrix` |
| Llenado aleatorio (0-1023) y manual (0-255) | 🟦 | `rand_lcg` (semilla vía `read_timer`), `mat_rand_fill`, `mat_manual_fill` |
| Suma con validación de dimensiones | 🟦 | `mat_op_sum` |
| Multiplicación A×B / B×A / ambas | 🟦 | `mat_op_mul` |
| Rotación múltiplos de 90° (cuadradas) | 🟦 | `mat_op_rot` |
| Submatriz de suma máxima | 🟦 | `mat_op_submax` |
| Mostrar matrices con buena presentación | 🟦 | `print_matrix` (encabezados, alineación) |
| Memoria dinámica | ✅ diseño propio | `memory.s` → `my_malloc`: bump allocator sobre heap estático 64 KB, alineación 8 bytes, chequeo de límites |
| Solo as/ld + syscalls (sin C) | ✅ | `macros.s` define syscalls crudas; sin libc en el link |

Todo el flujo interactivo queda 🟦 (verificado por lectura, no por corrida).

## 3. Fortalezas

1. Asignador de memoria propio con alineación y bounds-check — va más allá de "usar brk": diseño consciente.
2. Cobertura completa de las operaciones del enunciado, incluida la algorítmicamente no trivial (submatriz de suma máxima).
3. Macros de ensamblador para syscalls — abstracción idiomática de GNU as.
4. Makefile con toolchain sobreescribible (nativo RPi vs cross WSL/x86) y CI que compila.

## 4. Debilidades y riesgos

| Hallazgo | Severidad | Nota |
|---|---|---|
| Sin ejecución automatizada (CI build-only); `src/test.s` (31 líneas) no se integra al build | Media | Smoke test con QEMU sería viable |
| ~~Objetos `.o`, `matrix_app` y `testv` trackeados~~ | — | Corregido: `git rm --cached` (6 archivos) + `.gitignore`; pendiente de commit |
| `my_malloc` sin `free` real (bump allocator) — `free_matrix` existe pero el heap no se recicla | Baja | Aceptable y documentable como decisión |
| README anterior genérico con link de imagen roto | — | Reescrito en esta pasada (EN + resumen ES) |

## 5. Evaluación profesional

- Nivel demostrado: **Junior+ / Mid en bajo nivel**, misma banda que BattleshipARM pero con más carga algorítmica y de memoria; juntos forman un bloque de evidencia sólido de arquitectura de computadores.
- Impresión en 30 segundos (post-README): "operaciones de matrices + allocator propio en ASM" — diferenciador claro.

## 6. Recomendaciones

Ver `IMPROVEMENT_ROADMAP.md`. P1: smoke test QEMU en CI; commitear untracking de binarios.
