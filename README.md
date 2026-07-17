<div align="center">

# RISC Matrix App
### Matrix operations in pure ARM assembly, with a hand-rolled memory allocator

[![CI](https://github.com/Geovanni-Gonzalez/RISCMatrixApp/actions/workflows/ci.yml/badge.svg)](https://github.com/Geovanni-Gonzalez/RISCMatrixApp/actions/workflows/ci.yml)
![ARM](https://img.shields.io/badge/arch-ARMv7%20(gnueabihf)-red)
![Build](https://img.shields.io/badge/build-Make%20%2B%20GNU%20as%2Fld-blue)
![Platform](https://img.shields.io/badge/target-Raspberry%20Pi%20%2F%20QEMU-lightgrey)

</div>

Console application for creating and operating on matrices, written entirely in **ARM assembly** (~1,260 lines) for Raspberry Pi / QEMU, using only `as`, `ld`, and Linux syscalls — no C runtime, as required by the assignment ([`docs/Enunciado_Matrices_PY02.md`](docs/Enunciado_Matrices_PY02.md)).

![Demo](docs/img/principalImage.png)

## Features (all in assembly)

| Operation | Implementation |
|---|---|
| Matrix creation (2×2 to 20×20, non-square allowed) | `matrix.s` → `create_matrix`, validated input |
| Random fill (LCG, 0-1023) or manual entry (0-255) | `rand_lcg` seeded via `read_timer`, `mat_rand_fill`, `mat_manual_fill` |
| Sum (dimension-checked) | `mat_op_sum` |
| Multiplication (A×B, B×A, or both, feasibility-checked) | `mat_op_mul` |
| Rotation in 90° steps (square matrices) | `mat_op_rot` |
| **Maximum-sum submatrix** search | `mat_op_submax` |
| Formatted console rendering | `print_matrix` |
| **Custom memory allocator** (bump allocator over a 64 KB static heap, 8-byte aligned, bounds-checked) | `memory.s` → `my_malloc` |
| Syscall macros (exit, read, write, brk) | `macros.s` (GNU as macros) |
| Console I/O + int parsing/printing without libc | `utils.s` |

## Build & run

Requires `binutils-arm-linux-gnueabihf` (cross) or native ARM, plus `qemu-user` off-device.

```bash
make                          # native ARM (Raspberry Pi)
make AS=arm-linux-gnueabihf-as LD=arm-linux-gnueabihf-ld   # cross from x86
qemu-arm ./matrix_app         # run under emulation
```

CI (GitHub Actions) installs the ARM toolchain and builds on every push.

## Skills demonstrated

ARM assembly (ARMv7) · dynamic-memory design at the allocator level · pointer arithmetic over row-major matrices · assembler macro programming · algorithmics without abstractions (matrix multiply, rotation, max-sum submatrix) · GNU toolchain + Make · QEMU emulation.

## License

See [`LICENSE`](LICENSE).

## Author

**Geovanni González Aguilar** — Computer Engineering, Tecnológico de Costa Rica.

<details>
<summary><b>Resumen en español</b></summary>

Aplicación de consola para operaciones con matrices escrita íntegramente en ensamblador ARM (~1,260 líneas) para Raspberry Pi/QEMU, usando solo `as`, `ld` y syscalls de Linux (sin C, como exige el enunciado). Incluye creación de matrices 2×2-20×20 con llenado aleatorio (LCG) o manual, suma y multiplicación con validación de dimensiones, rotación en múltiplos de 90°, búsqueda de la submatriz de suma máxima, render formateado en consola y un asignador de memoria propio (bump allocator sobre heap estático de 64 KB con alineación de 8 bytes). Build con Makefile y CI en GitHub Actions.

</details>
