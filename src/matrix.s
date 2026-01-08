/*
 * matrix.s - Matrix Operations
 */
 
.include "src/macros.s"
.arm
.global create_matrix
.global free_matrix
.global mat_rand_fill
.global mat_manual_fill
.global rand_lcg
.global print_matrix
.global mat_op_sum
.global mat_op_mul
.global mat_op_rot
.global mat_op_submax

.section .data
    msg_rows: .ascii "Ingrese filas (2-20): \0"
    msg_cols: .ascii "Ingrese columnas (2-20): \0"
    msg_val:  .ascii "Valor: \0"
    seed:     .word 12345

.section .text

/*
 * rand_lcg: Generates pseudorandom number
 * Result: R0
 */
rand_lcg:
    push {r1, r2, r3, lr} @ 4 regs
    ldr r1, =seed
    ldr r0, [r1]
    ldr r2, =1103515245
    mul r0, r2, r0      @ Swapped: val * seed -> r0
    ldr r2, =12345      @ Load immediate to register
    add r0, r0, r2
    ldr r2, =0x7FFFFFFF
    and r0, r0, r2
    str r0, [r1]     @ Update seed
    pop {r1, r2, r3, pc}


/*
 * create_matrix: Allocates a Matrix Struct and its Data
 * Output: R0 = pointer to Matrix Struct (or 0)
 */
create_matrix:
    push {r4, r5, r6, lr} @ 4 regs = 16 bytes (Aligned)
    
    /* 1. Allocate Struct (12 bytes: rows, cols, data_ptr) */
    mov r0, #12
    bl my_malloc
    cmp r0, #0
    beq cm_fail
    mov r4, r0       @ R4 = Struct Ptr

    /* 2. Ask Dimensions */
    ldr r1, =msg_rows
    bl print_str
    bl read_int
    str r0, [r4, #0] @ Store rows
    mov r5, r0       @ R5 = rows

    ldr r1, =msg_cols
    bl print_str
    bl read_int
    str r0, [r4, #4] @ Store cols
    mul r5, r0, r5   @ R5 = rows*cols (total elements)

    /* 3. Allocate Data Block (Total * 4 bytes) */
    mov r0, r5
    lsl r0, r0, #2   @ Multiply by 4 (bytes per int)
    bl my_malloc
    cmp r0, #0
    beq cm_fail_data
    
    str r0, [r4, #8] @ Store data ptr in struct
    
    mov r0, r4       @ Return struct
    pop {r4, r5, r6, pc}

cm_fail_data:
    /* Ideally free struct here */
cm_fail:
    mov r0, #0
    pop {r4, r5, r6, pc}

/*
 * mat_rand_fill: Fills matrix with random values (0-1023)
 * Input: R0 = Matrix Ptr
 */
mat_rand_fill:
    push {r4, r5, r6, r7, r8, lr} @ 6 regs = 24 regs (wait 6*4=24, aligned to 8)
    mov r4, r0
    
    ldr r5, [r4, #0] @ Rows
    ldr r6, [r4, #4] @ Cols
    mul r5, r6, r5   @ Total elements
    ldr r4, [r4, #8] @ Data Ptr
    
mrf_loop:
    cmp r5, #0
    ble mrf_done
    
    bl rand_lcg
    ldr r1, =1023
    and r0, r0, r1   @ Modulo 1024 (using AND since 1023 is mask)
    
    str r0, [r4], #4 @ Store and increment
    sub r5, r5, #1
    b mrf_loop

mrf_done:
    pop {r4, r5, r6, r7, r8, pc}

/*
 * mat_manual_fill: Manual input (0-255)
 * Input: R0 = Matrix Ptr
 */
mat_manual_fill:
    push {r4, r5, r6, r7, r8, lr} @ 6 regs
    mov r4, r0
    
    ldr r5, [r4, #0] @ Rows
    ldr r6, [r4, #4] @ Cols
    mul r5, r6, r5   @ Total
    ldr r4, [r4, #8] @ Data Ptr
    
mmf_loop:
    cmp r5, #0
    ble mmf_done
    
    ldr r1, =msg_val
    bl print_str
    bl read_int
    
    /* Validation 0-255? */
    and r0, r0, #0xFF @ Force limit for safety or check? Just mask it.
    
    str r0, [r4], #4
    sub r5, r5, #1
    b mmf_loop

mmf_done:
    pop {r4, r5, r6, r7, r8, pc}

/*
 * print_matrix: Prints matrix to console
 * Input: R0 = Matrix Ptr
 */
print_matrix:
    push {r4, r5, r6, r7, r8, r9, r10, lr} @ 8 regs
    mov r4, r0
    cmp r4, #0
    beq pm_exit
    
    ldr r5, [r4, #0] @ Rows
    ldr r6, [r4, #4] @ Cols
    ldr r4, [r4, #8] @ Data
    
    mov r7, #0       @ Row counter
pm_row_loop:
    cmp r7, r5
    bge pm_exit
    
    /* Newline between rows */
    ldr r1, =newline
    bl print_str
    
    /* Print [ */
    mov r0, #'['
    bl print_char
    mov r0, #' '
    bl print_char
    
    mov r8, #0       @ Col counter
    
pm_col_loop:
    cmp r8, r6
    bge pm_row_done
    
    ldr r0, [r4], #4 @ Load int
    bl print_int
    
    /* Print spacer */
    ldr r1, =spacer
    bl print_str
    
    add r8, r8, #1
    b pm_col_loop

pm_row_done:
    /* Print ] */
    mov r0, #']'
    bl print_char

    add r7, r7, #1
    b pm_row_loop

pm_exit:
    ldr r1, =newline
    bl print_str
    pop {r4, r5, r6, r7, r8, r9, r10, pc}

/*
 * mat_op_sum: Adds Matrix A and B
 * Input: R0 = Mat A, R1 = Mat B
 */
mat_op_sum:
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr} @ 10 regs
    mov r4, r0
    mov r5, r1
    
    /* Validations */
    cmp r4, #0
    beq sum_fail
    cmp r5, #0
    beq sum_fail
    
    ldr r6, [r4, #0] @ A Rows
    ldr r7, [r4, #4] @ A Cols
    ldr r8, [r5, #0] @ B Rows
    ldr r9, [r5, #4] @ B Cols
    
    cmp r6, r8
    bne sum_fail
    cmp r7, r9
    bne sum_fail
    
    /* Create Result Matrix C manually? Or just print result? 
       Prompt says "Muestra... resultado". Doesn't explicitly say store.
       Let's print strictly.
    */
    
    ldr r0, =msg_res
    bl print_str
    
    ldr r6, [r4, #0] @ Rows
    ldr r7, [r4, #4] @ Cols
    mul r10, r6, r7 @ Total elements
    ldr r4, [r4, #8]
    ldr r5, [r5, #8]
    
    mov r8, #0 @ Row counter
sum_row_loop:
    cmp r8, r6
    bge sum_exit
    
    ldr r1, =newline
    bl print_str
    
    mov r9, #0 @ Col counter
sum_col_loop:
    cmp r9, r7
    bge sum_row_done
    
    ldr r0, [r4], #4
    ldr r1, [r5], #4
    add r0, r0, r1
    bl print_int
    
    ldr r1, =spacer
    bl print_str
    
    add r9, r9, #1
    b sum_col_loop

sum_row_done:
    add r8, r8, #1
    b sum_row_loop
    
sum_exit:
    ldr r1, =newline
    bl print_str
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

sum_fail:
    ldr r1, =msg_err_dim
    bl print_str
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

/*
 * mat_op_mul: Multiplies Matrix A and B
 * input: R0 = Mat A, R1 = Mat B
 */
/*
 * mat_op_mul: Multiplies Matrix A and B
 * input: R0 = Mat A, R1 = Mat B
 */
mat_op_mul:
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov r4, r0 @ A
    mov r5, r1 @ B
    
    cmp r4, #0
    beq mul_fail
    cmp r5, #0
    beq mul_fail
    
    ldr r6, [r4, #0] @ A Rows (M)
    ldr r7, [r4, #4] @ A Cols (N)
    ldr r8, [r5, #0] @ B Rows (N2)
    ldr r9, [r5, #4] @ B Cols (P)
    
    cmp r7, r8       @ Check N == N2
    bne mul_fail
    
    ldr r4, [r4, #8] @ A Data
    ldr r5, [r5, #8] @ B Data
    
    ldr r0, =msg_res_mul
    bl print_str
    
    mov r10, #0      @ i (0..M)
mul_outer_loop:
    cmp r10, r6
    bge mul_exit
    
    mov r11, #0      @ j (0..P)
    ldr r1, =newline
    bl print_str
    
mul_inner_loop:
    cmp r11, r9
    bge mul_outer_next
    
    mov r0, #0       @ Sum = 0
    mov r1, #0       @ k (0..N)
    
mul_dot_loop:
    cmp r1, r7
    bge mul_print_cell
    
    /* Calc Addr A: (i * N + k) * 4 */
    mul r2, r10, r7
    add r2, r2, r1
    lsl r2, r2, #2
    ldr r3, [r4, r2] @ A[i][k]
    
    /* Calc Addr B: (k * P + j) * 4 */
    mul r2, r1, r9
    add r2, r2, r11
    lsl r2, r2, #2
    ldr r12, [r5, r2] @ B[k][j]
    
    mul r3, r12, r3
    add r0, r0, r3   @ Sum += ...
    
    add r1, r1, #1
    b mul_dot_loop

mul_print_cell:
    bl print_int
    ldr r1, =spacer
    bl print_str
    
    add r11, r11, #1
    b mul_inner_loop

mul_outer_next:
    add r10, r10, #1
    b mul_outer_loop

mul_exit:
    ldr r1, =newline
    bl print_str
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

mul_fail:
    ldr r1, =msg_err_dim_mul
    bl print_str
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}


/*
 * mat_op_rot: Rotates Matrix 90 degrees Clockwise
 * Input: R0 = Matrix Ptr
 * Output: R0 = New Matrix Ptr (or 0 if fail/no change)
 */
mat_op_rot:
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov r4, r0
    
    cmp r4, #0
    beq rot_fail
    
    ldr r5, [r4, #0] @ Rows (M)
    ldr r6, [r4, #4] @ Cols (N)
    
    ldr r0, =msg_angle
    bl print_str
    bl read_int
    mov r7, r0       @ Angle
    
    /* Determine New Dimensions */
    cmp r7, #180
    moveq r8, r5     @ New Rows = M
    moveq r9, r6     @ New Cols = N
    beq rot_alloc
    
    /* 90 or 270: Swapped dimensions */
    mov r8, r6       @ New Rows = N
    mov r9, r5       @ New Cols = M

rot_alloc:
    /* Allocate Header (12 bytes) */
    mov r0, #12
    bl my_malloc
    mov r10, r0      @ New Struct Ptr
    str r8, [r10, #0] @ Store New Rows
    str r9, [r10, #4] @ Store New Cols
    
    /* Allocate Data */
    mul r0, r8, r9
    lsl r0, r0, #2
    bl my_malloc
    str r0, [r10, #8] @ Store New Data Ptr
    mov r11, r0      @ New Data Ptr
    
    ldr r4, [r4, #8] @ Old Data Ptr
    
    /* Loop through Old Matrix */
    mov r0, #0       @ i (0..M-1)
rot_outer:
    cmp r0, r5
    bge rot_done
    
    mov r1, #0       @ j (0..N-1)
rot_inner:
    cmp r1, r6
    bge rot_next_row
    
    /* Load Old[i][j] */
    mul r2, r0, r6
    add r2, r2, r1
    ldr r3, [r4, r2, lsl #2]
    
    /* Calc New Address based on angle */
    cmp r7, #180
    beq rot_calc_180
    mov r12, #210
    add r12, r12, #60 @ 270
    cmp r7, r12
    beq rot_calc_270
    
rot_calc_90: @ Default to 90 if not 180 or 270
    /* NewRow = j (r1), NewCol = (M-1) - i = (r5-1) - r0 */
    sub r12, r5, #1  @ M-1
    sub r12, r12, r0 @ (M-1) - i
    mul r2, r1, r9   @ j * NewCols (NewCols is M for 90/270)
    add r2, r2, r12  @ (j * NewCols) + ((M-1)-i)
    b rot_store

rot_calc_180:
    /* NewRow = (M-1) - i, NewCol = (N-1) - j */
    sub r12, r5, #1  @ M-1
    sub r12, r12, r0 @ (M-1) - i (NewRow)
    mul r2, r12, r9  @ NewRow * NewCols (NewCols is N for 180)
    sub r12, r6, #1  @ N-1
    sub r12, r12, r1 @ (N-1) - j (NewCol)
    add r2, r2, r12  @ (NewRow * NewCols) + NewCol
    b rot_store

rot_calc_270:
    /* NewRow = (N-1) - j, NewCol = i */
    sub r12, r6, #1  @ N-1
    sub r12, r12, r1 @ (N-1) - j (NewRow)
    mul r2, r12, r9  @ NewRow * NewCols (NewCols is M for 90/270)
    add r2, r2, r0   @ (NewRow * NewCols) + i (NewCol)
    
rot_store:
    str r3, [r11, r2, lsl #2]
    
    add r1, r1, #1
    b rot_inner

rot_next_row:
    add r0, r0, #1
    b rot_outer

rot_done:
    mov r0, r10      @ Return new matrix
    ldr r1, =msg_rot_done
    bl print_str
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

rot_fail:
    ldr r1, =msg_invalid_rot
    bl print_str
    mov r0, #0
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

/*
 * mat_op_submax: Finds max sum submatrix
 * Input: R0 = Matrix Ptr
 */
/*
 * kadane_1d: Finds max subarray sum
 * Input: R0 = ptr to array, R1 = length
 * Output: R0 = max sum
 */
kadane_1d:
    push {r4, r5, r6, r7, r8, lr}
    mov r4, r0         @ Array ptr
    mov r5, r1         @ Length
    
    ldr r6, =0x80000000 @ max_so_far = MIN_INT
    mov r7, #0         @ max_ending_here = 0
    
    mov r2, #0         @ Counter
k1d_loop:
    cmp r2, r5
    bge k1d_done
    
    ldr r3, [r4, r2, lsl #2]
    add r7, r7, r3
    
    cmp r6, r7
    movlt r6, r7       @ if (max_so_far < max_ending_here) max_so_far = max_ending_here
    
    cmp r7, #0
    movlt r7, #0       @ if (max_ending_here < 0) max_ending_here = 0
    
    add r2, r2, #1
    b k1d_loop

k1d_done:
    mov r0, r6
    pop {r4, r5, r6, r7, r8, pc}

/*
 * mat_op_submax: Finds max sum submatrix
 * Input: R0 = Matrix Ptr
 */
mat_op_submax:
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    sub sp, sp, #80    @ temp array (20*4 bytes)
    
    mov r4, r0         @ Matrix Ptr
    cmp r4, #0
    beq subm_exit
    
    ldr r5, [r4, #0]   @ Rows (M)
    ldr r6, [r4, #4]   @ Cols (N)
    ldr r4, [r4, #8]   @ Data Ptr
    
    ldr r7, =0x80000000 @ Global Max Sum (r7)
    
    mov r8, #0         @ topRow (r8)
top_row_loop:
    cmp r8, r5
    bge subm_print
    
    /* Clear temp array */
    mov r0, #0
clear_temp:
    cmp r0, r6
    bge start_bottom_row
    mov r1, #0
    add r2, sp, r0, lsl #2
    str r1, [r2]
    add r0, r0, #1
    b clear_temp

start_bottom_row:
    mov r9, r8         @ bottomRow (r9)
bottom_row_loop:
    cmp r9, r5
    bge next_top_row
    
    /* Update temp array with elements from current bottomRow */
    mov r10, #0        @ col counter (r10)
update_temp:
    cmp r10, r6
    bge run_kadane
    
    /* Element at [r9][r10]: DataPtr + (r9 * N + r10)*4 */
    mul r0, r9, r6
    add r0, r0, r10
    ldr r1, [r4, r0, lsl #2]
    
    /* temp[r10] += element */
    add r2, sp, r10, lsl #2
    ldr r3, [r2]
    add r3, r3, r1
    str r3, [r2]
    
    add r10, r10, #1
    b update_temp

run_kadane:
    mov r0, sp         @ temp array ptr
    mov r1, r6         @ length = Cols
    bl kadane_1d
    
    cmp r0, r7
    movgt r7, r0       @ Update Global Max
    
    add r9, r9, #1
    b bottom_row_loop

next_top_row:
    add r8, r8, #1
    b top_row_loop

subm_print:
    ldr r1, =msg_submax_res
    bl print_str
    mov r0, r7
    bl print_int
    ldr r1, =newline
    bl print_str
    
subm_exit:
    add sp, sp, #80
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

.section .data
    newline: .ascii "\n\0"
    spacer:  .ascii "  \0"
    msg_res: .ascii "\nResultado Suma:\n\0"
    msg_res_mul: .ascii "\nResultado Multiplicacion:\n\0"
    msg_err_dim: .ascii "Error: Dimensiones incompatibles.\n\0"
    msg_err_dim_mul: .ascii "Error: Cols A != Rows B.\n\0"
    msg_todo: .ascii "Funcion no implementada aun.\n\0"
    msg_angle: .ascii "Angulo (90, 180...): \0"
    msg_rot_done: .ascii "Rotacion Completa. Nueva Matriz asignada.\n\0"
    msg_sq_err: .ascii "Error: Matriz debe ser cuadrada.\n\0"
    msg_submax_res: .ascii "Suma Maxima: \0"
    msg_invalid_rot: .ascii "Error en Rotacion.\n\0"
