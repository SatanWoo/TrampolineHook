#if defined(__arm64__)

.text
.align 14
.globl _th_dynamic_page

interceptor:
.quad 0

.align 14
_th_dynamic_page:

_th_entry:

nop
nop
nop
nop
nop

sub x12, lr,   #0x8
sub x12, x12,  #0x4000
mov lr,  x13

ldr x10, [x12]

stp q0,  q1,   [sp, #-32]!
stp q2,  q3,   [sp, #-32]!
stp q4,  q5,   [sp, #-32]!
stp q6,  q7,   [sp, #-32]!

stp lr,  x10,  [sp, #-16]!
stp x0,  x1,   [sp, #-16]!
stp x2,  x3,   [sp, #-16]!
stp x4,  x5,   [sp, #-16]!
stp x6,  x7,   [sp, #-16]!
str x8,        [sp, #-16]!

ldr x8,  interceptor
blr x8

ldr x8,        [sp], #16
ldp x6,  x7,   [sp], #16
ldp x4,  x5,   [sp], #16
ldp x2,  x3,   [sp], #16
ldp x0,  x1,   [sp], #16
ldp lr,  x10,  [sp], #16

ldp q6,  q7,   [sp], #32
ldp q4,  q5,   [sp], #32
ldp q2,  q3,   [sp], #32
ldp q0,  q1,   [sp], #32

br  x10

.rept 2032
mov x13, lr
bl _th_entry;
.endr

#endif


