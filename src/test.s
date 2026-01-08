.include "src/macros.s"
.global _start
.section .data
    msg: .asciz "Hello ARM\n"
.section .text
_start:
    bic sp, sp, #7
    ldr r1, =msg
    bl print_str
    exit 0

print_str:
    push {r0-r7, lr}
    mov r0, r1
    bl string_length
    mov r2, r0
    mov r0, #1
    mov r7, #4
    swi 0
    pop {r0-r7, pc}

string_length:
    push {r1, lr}
    mov r1, r0
sl_loop:
    ldrb r2, [r1], #1
    cmp r2, #0
    bne sl_loop
    sub r0, r1, r0
    sub r0, r0, #1
    pop {r1, pc}
