//
//  THPageLayout.h
//  TrampolineHook
//
//  Created by z on 2020/5/18.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#ifndef THPageLayout_h
#define THPageLayout_h

#import <mach/vm_types.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>

#if defined(__arm64__)
#import "THPageDefinition_arm64.h"
#else
#error x86_64 to be supported
#endif

typedef struct {
    IMP originIMP;
} THDynamicData;

FOUNDATION_EXTERN void *THCreateDynamicePage(void *toMapAddress);

#endif /* THPageLayout_h */
