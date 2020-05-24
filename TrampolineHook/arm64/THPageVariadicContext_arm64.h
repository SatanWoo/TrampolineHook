//
//  THPageVariadicContext.h
//  TrampolineHook
//
//  Created by z on 2020/5/17.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#ifndef THPageVariadicContext_arm64_h
#define THPageVariadicContext_arm64_h

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
extern "C" {
#endif

// No use. Just for easy understanding of the memory layout
typedef struct _THPageVariadicContext {
    int64_t gR[10];              // general registers x0-x8 + x13
    int64_t vR[16];              // float   registers q0-q7
    int64_t linkRegister;        // lr
    int64_t originIMPRegister;   // origin
} THPageVariadicContext;

void THPageVariadicContextPre(void);
void THPageVariadicContextPost(void);
    
#ifdef __cplusplus
}
#endif


#endif /* THPageVariadicContext_arm64_h */
