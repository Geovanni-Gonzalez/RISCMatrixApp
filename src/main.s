/*
 * main.s - Entry point and Menu Loop
 */

.include "src/macros.s"
.global _start

.section .data
    msg_welcome: .ascii "\nRISC Matrix App - ARM Assembly\n\0"
    msg_menu:    .ascii "\n1. Crear Matrices\n2. Suma\n3. Multiplicacion\n4. Rotacion\n5. Submatriz Max\n6. Mostrar\n7. Salir\nOpcion: \0"
    msg_invalid: .ascii "Opcion Invalida.\n\0"
    
    buffer:      .space 20

.section .text

_start:
    /* Print Welcome */
    ldr r1, =msg_welcome
    mov r2, #32
    sys_write

menu_loop:
    /* Print Menu */
    ldr r1, =msg_menu
    mov r2, #100       @ Approx length, handle better in utils
    sys_write

    /* Read Option */
    ldr r1, =buffer
    mov r2, #5
    mov r0, #STDIN
    mov r7, #SYS_READ
    swi 0

    /* Check input */
    ldr r1, =buffer
    ldrb r3, [r1]
    
    cmp r3, #'1'
    beq do_create
    cmp r3, #'2'
    beq do_sum
    cmp r3, #'3'
    beq do_mul
    cmp r3, #'4'
    beq do_rot
    cmp r3, #'5'
    beq do_maxsub
    cmp r3, #'6'
    beq do_show
    cmp r3, #'7'
    beq exit_app
    
    ldr r1, =msg_invalid
    mov r2, #18
    sys_write
    b menu_loop

do_create:
    bl handle_create
    b menu_loop

do_show:
    bl handle_show
    b menu_loop

do_sum:
    bl handle_sum
    b menu_loop

do_mul:
    bl handle_mul
    b menu_loop

do_rot:
    bl handle_rot
    b menu_loop
    
do_maxsub:
    bl handle_maxsub
    b menu_loop

exit_app:
    exit 0

/* --- Subroutines for Menu Handling --- */

handle_create:
    push {lr}
    ldr r1, =msg_sel_mat
    bl print_str
    
    /* Read A/B selection */
    bl read_int @ But input is usually A or B char, let's use read buffer or naive
    /* We need a simple read_char really or just check buffer */
    /* Let's reuse buffer from main loop */
    ldr r1, =buffer
    mov r2, #5
    mov r0, #STDIN
    mov r7, #SYS_READ
    swi 0
    ldr r1, =buffer
    ldrb r3, [r1]
    
    /* Determine target pointer */
    cmp r3, #'A'
    ldreq r4, =matrixA
    cmp r3, #'B'
    ldreq r4, =matrixB
    /* If neither, maybe lowercase or invalid? Assume valid for MVP or check */
    
    /* Select Rand/Man */
    ldr r1, =msg_sel_mode
    bl print_str
    bl read_int
    mov r5, r0 @ Mode 1 or 2
    
    bl create_matrix @ Ask dims and malloc. Returns R0=Ptr
    cmp r0, #0
    beq hc_fail
    
    str r0, [r4] @ Save Matrix Ptr to global var
    
    /* Fill */
    cmp r5, #1
    bleq mat_rand_fill
    cmp r5, #2
    bleq mat_manual_fill
    
    ldr r1, =msg_done
    bl print_str
hc_fail:
    pop {pc}

handle_show:
    push {lr}
    ldr r1, =msg_matA
    bl print_str
    ldr r0, =matrixA
    ldr r0, [r0]
    cmp r0, #0
    bleq print_matrix
    
    ldr r1, =msg_matB
    bl print_str
    ldr r0, =matrixB
    ldr r0, [r0]
    cmp r0, #0
    bleq print_matrix
    
    pop {pc}

handle_sum:
    push {lr}
    ldr r0, =matrixA
    ldr r0, [r0]
    ldr r1, =matrixB
    ldr r1, [r1]
    bl mat_op_sum
    pop {pc}
    
handle_mul:
    push {lr}
    ldr r0, =matrixA
    ldr r0, [r0]
    ldr r1, =matrixB
    ldr r1, [r1]
    bl mat_op_mul
    pop {pc}

handle_rot:
    push {lr}
    ldr r1, =msg_sel_mat
    bl print_str
    
    /* Read selection (reuse buffer) */
    ldr r1, =buffer
    mov r2, #5
    mov r0, #STDIN
    mov r7, #SYS_READ
    swi 0
    ldr r1, =buffer
    ldrb r3, [r1]
    
    ldr r4, =matrixA
    cmp r3, #'B'
    ldreq r4, =matrixB
    
    ldr r0, [r4]
    bl mat_op_rot
    
    cmp r0, #0
    beq hr_done
    
    str r0, [r4] @ Update global pointer with new matrix
hr_done:
    pop {pc}

handle_maxsub:
    push {lr}
    ldr r1, =msg_sel_mat
    bl print_str
    
    /* Read selection */
    ldr r1, =buffer
    mov r2, #5
    mov r0, #STDIN
    mov r7, #SYS_READ
    swi 0
    ldr r1, =buffer
    ldrb r3, [r1]
    
    ldr r4, =matrixA
    cmp r3, #'B'
    ldreq r4, =matrixB
    
    ldr r0, [r4]
    bl mat_op_submax
    pop {pc}


.section .data
    /* Existing msgs... */
    msg_sel_mat: .ascii "Seleccione Matriz (A/B): \0"
    msg_sel_mode: .ascii "Modo (1=Auto, 2=Man): \0"
    msg_done: .ascii "Matriz Creada.\n\0"
    msg_matA: .ascii "\n--- Matriz A ---\n\0"
    msg_matB: .ascii "\n--- Matriz B ---\n\0"

.section .bss
    matrixA: .word 0
    matrixB: .word 0
