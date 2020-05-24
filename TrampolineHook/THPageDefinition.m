//
//  THPageLayout.m
//  TrampolineHook
//
//  Created by z on 2020/5/18.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "THPageDefinition.h"

void *THCreateDynamicePage(void *toMapAddress)
{
    if (!toMapAddress) return NULL;
    
    vm_address_t fixedPage = (vm_address_t)toMapAddress;
    
    vm_address_t newDynamicPage = 0;
    kern_return_t kernResult = KERN_SUCCESS;

    kernResult = vm_allocate(current_task(), &newDynamicPage, PAGE_SIZE * 2, VM_FLAGS_ANYWHERE);
    NSCAssert1(kernResult == KERN_SUCCESS, @"[THDynamicPage]::vm_allocate failed", kernResult);
    
    vm_address_t newCodePageAddress = newDynamicPage + PAGE_SIZE;
    kernResult = vm_deallocate(current_task(), newCodePageAddress, PAGE_SIZE);
    NSCAssert1(kernResult == KERN_SUCCESS, @"[THDynamicPage]::vm_deallocate failed", kernResult);
    
    vm_prot_t currentProtection, maxProtection;
    kernResult = vm_remap(current_task(), &newCodePageAddress, PAGE_SIZE, 0, 0, current_task(), fixedPage, FALSE, &currentProtection, &maxProtection, VM_INHERIT_SHARE);
    NSCAssert1(kernResult == KERN_SUCCESS, @"[THDynamicPage]::vm_remap failed", kernResult);
    
    return (void *)newDynamicPage;
}
