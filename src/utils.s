/*
 * utils.s - Helper functions for IO
 */
 
.include "src/macros.s"
.global print_str
.global read_int
.global print_int
.global string_length
.global read_timer

.section .text

/* 
 * string_length: Calculates length of null-terminated string
 * Input: R0 = string address
 * Output: R0 = length
 */
string_length:
    push {r1, lr}
    mov r1, r0
sl_loop:
    ldrb r2, [r1], #1
    cmp r2, #0
    bne sl_loop
    sub r0, r1, r0
    sub r0, r0, #1     @ Adjust for null
    pop {r1, pc}

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
    swi 0
    pop {r0, r2, r7, pc}

/*
 * print_int: Prints integer in R0 to stdout
 * Input: R0 = integer
 */
print_int:
    push {r0-r8, lr}
    mov r4, r0         @ Number to print
    ldr r5, =int_buffer
    add r5, r5, #19    @ Point to end of buffer
    mov r6, #0         @ Null terminator
    strb r6, [r5]
    
    mov r7, #10        @ Divisor
    
    cmp r4, #0
    bge pi_loop
    neg r4, r4         @ Handle negative? Simple version unsigned for now unless needed
    
pi_loop:
    /* Divide R4 by 10. ARM has no DIV instruction in older archs, 
     * but Raspberry Pi usually supports UDIV. We will assume UDIV exists.
     */
    udiv r8, r4, r7    @ R8 = R4 / 10
    mul r9, r8, r7     @ R9 = R8 * 10
    sub r0, r4, r9     @ R0 = R4 % 10 (Remainder)
    
    add r0, r0, #48    @ Convert to ASCII
    sub r5, r5, #1
    strb r0, [r5]
    
    mov r4, r8
    cmp r4, #0
    bgt pi_loop
    
    mov r1, r5         @ Start print from here
    bl print_str
    
    pop {r0-r8, pc}

/*
 * read_int: Reads string from stdin and converts to int
 * Output: R0 = integer
 */
read_int:
    push {r1-r7, lr}
    ldr r1, =int_buffer
    mov r2, #20
    mov r0, #STDIN
    mov r7, #SYS_READ
    swi 0
    
    /* ATOI Logic */
    ldr r1, =int_buffer
    mov r0, #0         @ Result
    mov r3, #0         @ Counter
    mov r4, #10        @ Multiplier

atoi_loop:
    ldrb r2, [r1, r3]
    cmp r2, #10        @ Newline
    beq atoi_done
    cmp r2, #0         @ Null
    beq atoi_done
    cmp r2, #'0'
    blt atoi_done
    cmp r2, #'9'
    bgt atoi_done
    
    sub r2, r2, #'0'
    mul r0, r4, r0     @ Swapped: 10 * acc -> r0
    add r0, r0, r2
    
    add r3, r3, #1
    b atoi_loop

atoi_done:
    pop {r1-r7, pc}

/*
 * read_timer: Returns usage of system timer (rough random seed)
 * This works on specific hardware, for emulation we might use time syscall (gettimeofday)
 * For simplicity, we'll try sys_gettimeofday (78)
 */
read_timer:
    push {r1-r7, lr}
    ldr r0, =time_struct
    mov r1, #0
    mov r7, #78        @ SYS_GETTIMEOFDAY
    swi 0
    ldr r0, =time_struct
    ldr r0, [r0, #4]   @ Use microseconds as seed
    pop {r1-r7, pc}

.section .bss
    int_buffer: .space 20
    time_struct: .space 8  @ tv_sec, tv_usec
