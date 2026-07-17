# CV_EVIDENCE — RISCMatrixApp

Verifiable, interview-defensible material. Pairs with BattleshipARM as the low-level evidence block; below is what this repo adds beyond it.

## Resume bullets (pick & adapt)

- Implemented a matrix-operations console application in pure ARM assembly (~1,260 lines) for Raspberry Pi/QEMU: creation with validated dimensions, random (LCG) and manual fill, dimension-checked addition and multiplication, 90°-step rotation, and maximum-sum submatrix search — no C runtime, syscalls only.
- Designed a custom memory allocator in assembly: bump allocation over a 64 KB static heap with 8-byte alignment and bounds checking, exposed as `my_malloc` to the rest of the program.
- Wrote reusable GNU assembler macros for the Linux syscall interface (read/write/exit/brk) and libc-free integer parsing/printing routines.

## Unique evidence (vs. BattleshipARM)

| Item | Evidence |
|---|---|
| Memory-allocator design (alignment, bounds, pointer bookkeeping) | `src/memory.s` → `my_malloc` |
| Pointer arithmetic over dynamic 2-D structures (row-major, non-square) | `src/matrix.s` |
| Non-trivial algorithm in assembly (max-sum submatrix) | `src/matrix.s` → `mat_op_submax` |
| GNU as macro programming | `src/macros.s` |
| Cross/native dual toolchain build | `Makefile` (overridable AS/LD) |

## Reinforces

ARM assembly, AAPCS discipline, Linux syscalls, Make, QEMU, CI with real ARM toolchain (all shared with BattleshipARM).

## ATS keywords (incremental)

Memory allocator, heap management, pointer arithmetic, dynamic memory, assembler macros, Raspberry Pi, RISC architecture, algorithm implementation, matrix operations.
