# IMPROVEMENT_ROADMAP — RISCMatrixApp

Backlog priorizado. Impacto/Esfuerzo: Alto/Medio/Bajo.

## Quick Wins

| # | Mejora | Impacto | Esfuerzo | Prioridad |
|---|---|---|---|---|
| 1 | Commitear el untracking de `matrix_app`, `testv` y los 4 `.o` (aplicado en esta revisión) | Medio | Bajo | P0 |
| 2 | GitHub Topics: `arm`, `assembly`, `raspberry-pi`, `qemu`, `low-level`, `matrix` + descripción | Medio | Bajo | P1 |
| 3 | Captura/GIF real de la salida de `print_matrix` (la presentación visual puntuaba en el enunciado) | Medio | Bajo | P1 |

## Mejoras técnicas

| # | Mejora | Impacto | Esfuerzo | Prioridad |
|---|---|---|---|---|
| 4 | Smoke test en CI: `qemu-user` + entrada guionizada verificando una suma 2×2 conocida | Alto | Medio | P1 |
| 5 | Integrar o eliminar `src/test.s` (hoy no participa del build) | Bajo | Bajo | P2 |
| 6 | Documentar la decisión "bump allocator sin free" en un comentario de cabecera de `memory.s` | Bajo | Bajo | P2 |
| 7 | Documentar la complejidad del `mat_op_submax` (y, si es fuerza bruta, mencionar la alternativa Kadane 2D) | Medio | Bajo | P2 |

## Mejoras arquitectónicas

Ninguna prioritaria: el valor del repo es demostrativo. Las horas técnicas adicionales rinden más en el bloque de compiladores o en Rescue-Pet/Match-3.

## Mejoras de GitHub

Ya presentes: badge CI, LICENSE, `.gitignore` (con `*.o`), enunciado en docs. Faltan: Topics (item 2), captura real (item 3).
