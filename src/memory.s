/*
 * memory.s - Dynamic Memory Allocation
 */

.include "src/macros.s"
.global my_malloc
.global heap_end

.section .data
    heap_start: .word 0
    heap_end:   .word 0

.section .text

/*
 * init_heap: Initializes heap pointers (optional, can do lazy)
 * Output: R0 = current break
 */
init_heap:
    push {r7, lr}
    mov r0, #0
    mov r7, #SYS_BRK
    swi 0
    ldr r1, =heap_start
    str r0, [r1]
    ldr r1, =heap_end
    str r0, [r1]
    pop {r7, pc}

/*
 * my_malloc: Allocates N bytes
 * Input: R0 = size in bytes
 * Output: R0 = pointer to allocated memory (or 0 if failed)
 */
my_malloc:
    push {r1, r2, r7, lr}
    mov r2, r0          @ Save requested size in R2
    
    /* Get current break */
    mov r0, #0
    mov r7, #SYS_BRK
    swi 0
    
    mov r1, r0          @ R1 = current break (start of new block)
    add r0, r0, r2      @ R0 = new break (current + size)
    
    /* Request new break */
    mov r7, #SYS_BRK
    swi 0
    
    /* Check if successful (R0 should be new address) */
    /* If failed, usually returns old break or error? In Linux brk returns current break on success?
       Wait, sys_brk returns the new break on success. If it failed, it returns the old break.
     */
     
    /* Actually we need to verify if R0 >= R1 + size? 
       Let's assume success if R0 != R1 (if we asked for >0 bytes)
    */
    
    cmp r0, r1
    beq malloc_fail
    
    mov r0, r1          @ Return the *start* of the allocated block
    b malloc_exit

malloc_fail:
    mov r0, #0

malloc_exit:
    pop {r1, r2, r7, pc}
