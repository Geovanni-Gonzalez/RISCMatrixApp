/* 
 * macros.s - System Call Macros for Raspberry Pi (ARM)
 */

.equ SYS_EXIT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_BRK, 45
.equ STDIN, 0
.equ STDOUT, 1

/* Macro to exit the program */
.macro exit code
    mov r0, #\code
    mov r7, #SYS_EXIT
    swi 0
.endm

/* Macro to write to stdout 
 * Args: buffer (ptr), length (imm/reg)
 */
.macro print str, len
    mov r0, #STDOUT
    ldr r1, =\str
    mov r2, #\len
    mov r7, #SYS_WRITE
    swi 0
.endm

/* Macro for simple write if regs are already set 
 * R1 = buf, R2 = len 
 */
.macro sys_write
    mov r0, #STDOUT
    mov r7, #SYS_WRITE
    swi 0
.endm

/* Macro to read from stdin
 * Args: buffer (ptr), length (imm/reg)
 */
.macro read buf, len
    mov r0, #STDIN
    ldr r1, =\buf
    mov r2, #\len
    mov r7, #SYS_READ
    swi 0
.endm
