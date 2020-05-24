#if defined(__arm64__)

// data page
.text
.align 14
.globl _th_dynamic_page_var

interceptor:
.quad 0

pre:
.quad 0

post:
.quad 0

// code page

.align 14
_th_dynamic_page_var:

_th_entry_var:

nop

sub x12, lr,   #0x8
sub x12, x12,  #0x4000

ldr x10, [x12]

ldr x8,  pre
blr x8

ldr x8,  interceptor
blr x8

ldr x8,  post
br  x8

.rept 2043
mov x13, lr
bl _th_entry_var;
.endr

#endif


