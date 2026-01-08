/*
 * main.s - Entry point and Menu Loop
 */

.include "src/macros.s"
.arm
.global _start

.section .data
.align 4
    msg_banner: .ascii "\n  ____  ___ ____  ______ \n |  _ \\|_ _/ ___|/ ___\\ \\\n | |_) || |\\___ \\| |   \\ \\\n |  _ < | | ___) | |___/ /\n |_| \\_\\___|____/ \\____/_/\n     MATRIX APP v1.0\n\0"
    msg_press_enter: .ascii "\n[Presione Enter para continuar...]\0"
    msg_menu:    .ascii "\n1. Crear Matrices\n2. Suma\n3. Multiplicacion\n4. Rotacion\n5. Submatriz Max\n6. Mostrar\n7. Salir\n\n> Seleccione Opcion: \0"
    msg_invalid: .ascii "Opcion Invalida.\n\0"
    msg_rows: .ascii "Ingrese filas (2-20): \0"
    
    buffer:      .space 20

.section .text

_start:
    /* Clear Screen & Print Banner */
    bl clear_screen
    bl set_color_cyan
    ldr r1, =msg_banner
    bl print_str
    bl reset_color

menu_loop:
    bl clear_screen
    bl set_color_cyan
    ldr r1, =msg_banner
    bl print_str
    bl reset_color

    /* Print Menu */
    bl set_color_green
    ldr r1, =msg_menu
    bl print_str
    bl reset_color

    /* Read Option */
    ldr r1, =buffer
    mov r2, #5
    mov r0, #STDIN
    mov r7, #SYS_READ
    svc 0

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
    
    bl set_color_red
    ldr r1, =msg_invalid
    bl print_str
    bl reset_color
    bl wait_for_user
    b menu_loop

do_create:
    bl handle_create
    bl wait_for_user
    b menu_loop

do_show:
    bl handle_show
    bl wait_for_user
    b menu_loop

do_sum:
    bl handle_sum
    bl wait_for_user
    b menu_loop

do_mul:
    bl handle_mul
    bl wait_for_user
    b menu_loop

do_rot:
    bl handle_rot
    bl wait_for_user
    b menu_loop
    
do_maxsub:
    bl handle_maxsub
    bl wait_for_user
    b menu_loop

exit_app:
    exit 0

/* --- Subroutines for Menu Handling --- */

handle_create:
    push {r4, lr}
    ldr r1, =msg_sel_mat
    bl print_str
    
    /* Read A/B selection */
    ldr r1, =buffer
    mov r2, #10
    mov r0, #STDIN
    mov r7, #SYS_READ
    svc 0
    ldr r1, =buffer
    ldrb r3, [r1]
    
    /* Determine target pointer */
    cmp r3, #'A'
    ldreq r4, =matrixA
    cmp r3, #'a'
    ldreq r4, =matrixA
    cmp r3, #'B'
    ldreq r4, =matrixB
    cmp r3, #'b'
    ldreq r4, =matrixB
    
    cmp r4, #0
    beq hc_fail
    
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
    pop {r4, pc}

handle_show:
    push {r4, lr}
    ldr r1, =msg_matA
    bl print_str
    ldr r0, =matrixA
    ldr r0, [r0]
    cmp r0, #0
    blne print_matrix
    
    ldr r1, =msg_matB
    bl print_str
    ldr r0, =matrixB
    ldr r0, [r0]
    cmp r0, #0
    blne print_matrix
    
    pop {r4, pc}

handle_sum:
    push {r4, lr}
    ldr r0, =matrixA
    ldr r0, [r0]
    ldr r1, =matrixB
    ldr r1, [r1]
    bl mat_op_sum
    pop {r4, pc}
    
handle_mul:
    push {r4, lr}
    ldr r0, =matrixA
    ldr r0, [r0]
    ldr r1, =matrixB
    ldr r1, [r1]
    bl mat_op_mul
    pop {r4, pc}

handle_rot:
    push {r4, lr}
    ldr r1, =msg_sel_mat
    bl print_str
    
    /* Read selection (reuse buffer) */
    ldr r1, =buffer
    mov r2, #5
    mov r0, #STDIN
    mov r7, #SYS_READ
    svc 0
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
    pop {r4, pc}

handle_maxsub:
    push {r4, lr}
    ldr r1, =msg_sel_mat
    bl print_str
    
    /* Read selection */
    ldr r1, =buffer
    mov r2, #5
    mov r0, #STDIN
    mov r7, #SYS_READ
    svc 0
    ldr r1, =buffer
    ldrb r3, [r1]
    
    ldr r4, =matrixA
    cmp r3, #'B'
    ldreq r4, =matrixB
    
    ldr r0, [r4]
    bl mat_op_submax
    ldmfd sp!, {r4, pc}

/*
 * wait_for_user: Pauses until Enter is pressed
 */
wait_for_user:
    push {r4, lr}
    ldr r1, =msg_press_enter
    bl print_str
    
    ldr r1, =buffer
    mov r2, #1       @ Read 1 char
    mov r0, #STDIN
    mov r7, #SYS_READ
    svc 0
    
    pop {r4, pc}

.section .data
.align 4
    /* Existing msgs... */
    msg_sel_mat: .ascii "Seleccione Matriz (A/B): \0"
    msg_sel_mode: .ascii "Modo (1=Auto, 2=Man): \0"
    msg_done: .ascii "Matriz Creada.\n\0"
    msg_matA: .ascii "\n--- Matriz A ---\n\0"
    msg_matB: .ascii "\n--- Matriz B ---\n\0"

.section .bss
.align 4
    matrixA: .word 0
    matrixB: .word 0
