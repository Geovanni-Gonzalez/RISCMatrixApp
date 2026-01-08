/*
 * memory.s - Static Memory Allocator
 */

.global my_malloc

.section .bss
.align 4
    static_heap: .space 65536  @ 64KB heap
    heap_ptr:    .word 0

.section .text

/*
 * my_malloc: Returns pointer from static buffer
 * Input: R0 = size
 */
my_malloc:
    push {r1, r2, lr}
    
    @ Align size to 8 bytes
    add r0, r0, #7
    bic r0, r0, #7
    
    ldr r1, =heap_ptr
    ldr r2, [r1]
    
    cmp r2, #0
    ldreq r2, =static_heap  @ Init on first call
    
    mov r3, r2              @ Current available address
    add r2, r2, r0          @ Advance pointer
    
    @ Check bounds
    ldr r12, =static_heap
    add r12, r12, #65536
    cmp r2, r12
    bhi malloc_fail
    
    str r2, [r1]            @ Save new pointer
    mov r0, r3              @ Return old pointer
    pop {r1, r2, pc}

malloc_fail:
    mov r0, #0
    pop {r1, r2, pc}
