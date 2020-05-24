//
//  THPageVariadicContext.m
//  TrampolineHook
//
//  Created by z on 2020/5/17.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "THPageVariadicContext_arm64.h"

#if defined(__arm64__)

// lr -  跳向 interceptor 的下一跳地址
// x13 - 替换前原调用函数的下一跳地址

#define saveRegs() \
__asm volatile ( \
"stp q0,  q1,   [sp, #-32]!\n" \
"stp q2,  q3,   [sp, #-32]!\n" \
"stp q4,  q5,   [sp, #-32]!\n" \
"stp q6,  q7,   [sp, #-32]!\n" \
"stp lr,  x10,  [sp, #-16]!\n" \
"stp x0,  x1,   [sp, #-16]!\n" \
"stp x2,  x3,   [sp, #-16]!\n" \
"stp x4,  x5,   [sp, #-16]!\n" \
"stp x6,  x7,   [sp, #-16]!\n" \
"stp x8,  x13,  [sp, #-16]!\n" \
)

#define restoreRegs() \
__asm volatile( \
"ldp x8,  x13,  [sp], #16\n" \
"ldp x6,  x7,   [sp], #16\n" \
"ldp x4,  x5,   [sp], #16\n" \
"ldp x2,  x3,   [sp], #16\n" \
"ldp x0,  x1,   [sp], #16\n" \
"ldp lr,  x10,  [sp], #16\n" \
"ldp q6,  q7,   [sp], #32\n" \
"ldp q4,  q5,   [sp], #32\n" \
"ldp q2,  q3,   [sp], #32\n" \
"ldp q0,  q1,   [sp], #32\n" \
)

__attribute__((__naked__))
void THPageVariadicContextPre(void)
{
    // 先保存，避免调用 malloc 破坏寄存器
    saveRegs();
    
    // 分配堆上内存 extra 16 byte + sizeof(THPageVariadicContext)
    __asm volatile ("mov x0, #0xF0");
    __asm volatile ("bl _malloc");
    
    // 返回的分配内存地址保存起来 callee-saved
    __asm volatile ("str x19, [x0]");
    __asm volatile ("mov x19, x0");
    
    // 恢复堆栈，避免影响变参所处在的堆栈
    restoreRegs();
    
    // 用堆上空间保存数据
    __asm volatile ("stp x0, x1,  [x19, #(16 + 0 * 16)]");
    __asm volatile ("stp x2, x3,  [x19, #(16 + 1 * 16)]");
    __asm volatile ("stp x4, x5,  [x19, #(16 + 2 * 16)]");
    __asm volatile ("stp x6, x7,  [x19, #(16 + 3 * 16)]");
    __asm volatile ("stp x8, x13, [x19, #(16 + 4 * 16)]");
    
    __asm volatile ("stp q0, q1,  [x19, #(16 + 5 * 16 + 0 * 32)]");
    __asm volatile ("stp q2, q3,  [x19, #(16 + 5 * 16 + 1 * 32)]");
    __asm volatile ("stp q4, q5,  [x19, #(16 + 5 * 16 + 2 * 32)]");
    __asm volatile ("stp q6, q7,  [x19, #(16 + 5 * 16 + 3 * 32)]");
    
    __asm volatile ("stp lr, x10, [x19, #(16 + 5 * 16 + 4 * 32)]");
    
    __asm volatile ("ret");
}

__attribute__((__naked__))
void THPageVariadicContextPost(void)
{
    // x19 肯定是正确的地址，使用x19恢复对应的数据
    __asm volatile ("ldp lr, x10, [x19, #(16 + 5 * 16 + 4 * 32)]");
    __asm volatile ("ldp q6, q7,  [x19, #(16 + 5 * 16 + 3 * 32)]");
    __asm volatile ("ldp q4, q5,  [x19, #(16 + 5 * 16 + 2 * 32)]");
    __asm volatile ("ldp q2, q3,  [x19, #(16 + 5 * 16 + 1 * 32)]");
    __asm volatile ("ldp q0, q1,  [x19, #(16 + 5 * 16 + 0 * 32)]");
    
    __asm volatile ("ldp x8, x13, [x19, #(16 + 4 * 16)]");
    __asm volatile ("ldp x6, x7,  [x19, #(16 + 3 * 16)]");
    __asm volatile ("ldp x4, x5,  [x19, #(16 + 2 * 16)]");
    __asm volatile ("ldp x2, x3,  [x19, #(16 + 1 * 16)]");
    __asm volatile ("ldp x0, x1,  [x19, #(16 + 0 * 16)]");
   
    // 保存一下，避免 free 的影响。
    saveRegs();
    
    // 恢复原先的 x19, 调用free
    __asm volatile ("mov x0, x19");
    __asm volatile ("ldr x19, [x19]");
    __asm volatile ("bl _free");
     
    // 恢复堆栈
    restoreRegs();
    
    __asm volatile ("mov lr, x13");
    __asm volatile ("br x10");
}

#endif
