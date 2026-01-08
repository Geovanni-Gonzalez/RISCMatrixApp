/*
 * utils.s - Helper functions for IO
 */
 
.include "src/macros.s"
.arm
.global print_str
.global read_int
.global print_int
.global string_length
.global read_timer
.global print_char
.global clear_screen
.global set_color_cyan
.global set_color_green
.global set_color_red
.global reset_color

.section .text

/* 
 * string_length: Calculates length of null-terminated string
 * Input: R0 = string address
 * Output: R0 = length
 */
string_length:
    push {r1, r2, r3, lr} @ 4 regs = 16 bytes
    mov r1, r0
sl_loop:
    ldrb r2, [r1], #1
    cmp r2, #0
    bne sl_loop
    sub r0, r1, r0
    sub r0, r0, #1     @ Adjust for null
    pop {r1, r2, r3, pc}

/*
 * print_str: Prints null-terminated string
 * Input: R1 = string address
 */
print_str:
    push {r0, r2, r7, lr}
    mov r0, r1         @ Move string to R0 for length calc
    bl string_length
    mov r2, r0         @ Length in R2
    mov r0, #STDOUT
    mov r7, #SYS_WRITE
    svc 0
    pop {r0, r2, r7, pc}

/*
 * print_int: Prints integer in R0 to stdout
 * Input: R0 = integer
 */
print_int:
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, lr}
    mov r4, r0         @ Number to print
    ldr r5, =int_buffer
    add r5, r5, #19    @ Point to end of buffer
    mov r6, #0         @ Null terminator
    strb r6, [r5]
    
    mov r7, #10        @ Divisor
    
    cmp r4, #0
    bge pi_loop
    
    /* Handle negative */
    neg r4, r4
    push {r0, r1, r4, r5} @ 4 regs
    ldr r1, =minus_sign
    bl print_str
    pop {r0, r1, r4, r5}
    
pi_loop:
    /* Manual division by 10 */
    mov r8, #0         @ Quotient
    mov r0, r4         @ Remainder
pi_div_loop:
    cmp r0, #10
    blt pi_div_done
    sub r0, r0, #10
    add r8, r8, #1
    b pi_div_loop
pi_div_done:
    @ R8 = Quotient, R0 = Remainder
    
    add r0, r0, #48    @ Convert to ASCII
    sub r5, r5, #1
    strb r0, [r5]
    
    mov r4, r8
    cmp r4, #0
    bgt pi_loop
    
    mov r1, r5         @ Start print from here
    bl print_str
    
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, pc}

.section .data
    minus_sign: .ascii "-\0"

/*
 * read_int: Reads string from stdin and converts to int
 * Output: R0 = integer
 */
read_int:
    push {r1, r2, r3, r4, r5, r6, r7, lr} @ 8 regs = 32 bytes
    ldr r1, =int_buffer
    mov r2, #20
    mov r0, #STDIN
    mov r7, #SYS_READ
    svc 0
    
    /* ATOI Logic */
    ldr r1, =int_buffer
    mov r0, #0         @ Result
    mov r3, #0         @ Counter
    mov r4, #10        @ Multiplier
    mov r5, #1         @ Sign (1 = positive)

    /* Check for negative sign */
    ldrb r2, [r1, r3]
    cmp r2, #'-'
    bne atoi_loop
    mov r5, #-1
    add r3, r3, #1

atoi_loop:
    ldrb r2, [r1, r3]
    cmp r2, #10        @ Newline
    beq atoi_apply_sign
    cmp r2, #0         @ Null
    beq atoi_apply_sign
    cmp r2, #'0'
    blt atoi_apply_sign
    cmp r2, #'9'
    bgt atoi_apply_sign
    
    sub r2, r2, #'0'
    mul r0, r4, r0
    add r0, r0, r2
    
    add r3, r3, #1
    b atoi_loop

atoi_apply_sign:
    mul r0, r5, r0
    pop {r1, r2, r3, r4, r5, r6, r7, pc}

/*
 * read_timer: Returns usage of system timer (rough random seed)
 * This works on specific hardware, for emulation we might use time syscall (gettimeofday)
 * For simplicity, we'll try sys_gettimeofday (78)
 */
read_timer:
    push {r1, r2, r3, r4, r5, r6, r7, lr} @ 8 regs = 32 bytes
    ldr r0, =time_struct
    mov r1, #0
    mov r7, #78        @ SYS_GETTIMEOFDAY
    svc 0
    ldr r0, =time_struct
    ldr r0, [r0, #4]   @ Use microseconds as seed
    pop {r1, r2, r3, r4, r5, r6, r7, pc}

.section .bss
    int_buffer: .space 20
    time_struct: .space 8  @ tv_sec, tv_usec

.section .data
    /* ANSI Escape Codes */
    ansi_cls:   .asciz "\033[2J\033[H"
    ansi_cyan:  .asciz "\033[1;36m"
    ansi_green: .asciz "\033[1;32m"
    ansi_red:   .asciz "\033[1;31m"
    ansi_reset: .asciz "\033[0m"

.section .text

/*
 * print_char: Prints a single character
 * Input: R0 = char
 */
print_char:
    push {r0, r1, r2, r7, r8, lr} @ 6 regs
    sub sp, sp, #8
    strb r0, [sp]
    
    mov r0, #STDOUT
    mov r1, sp
    mov r2, #1
    mov r7, #SYS_WRITE
    svc 0
    
    add sp, sp, #8
    pop {r0, r1, r2, r7, r8, pc}

/*
 * clear_screen: Clears terminal
 */
clear_screen:
    push {r4, lr}
    ldr r1, =ansi_cls
    bl print_str
    pop {r4, pc}

set_color_cyan:
    push {r4, lr}
    ldr r1, =ansi_cyan
    bl print_str
    pop {r4, pc}

set_color_green:
    push {r4, lr}
    ldr r1, =ansi_green
    bl print_str
    pop {r4, pc}

set_color_red:
    push {r4, lr}
    ldr r1, =ansi_red
    bl print_str
    pop {r4, pc}

reset_color:
    push {r4, lr}
    ldr r1, =ansi_reset
    bl print_str
    pop {r4, pc}
