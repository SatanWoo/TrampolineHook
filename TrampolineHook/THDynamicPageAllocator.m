//
//  THDynamicAllocator.m
//  TrampolineHook
//
//  Created by z on 2020/4/25.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "THDynamicPageAllocator.h"
#import <AssertMacros.h>
#import <objc/message.h>
#import <mach/vm_types.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>

FOUNDATION_EXTERN id th_dynamic_page(id, SEL);

typedef struct {
    IMP originIMP;
} THDynamicData;

#if defined(__arm64__)
#import "THPageDefinition_arm64.h"
#else
#error x86_64 & arm64e to be supported
#endif

static const size_t THNumberOfDataPerPage = (0x4000 - THDynamicPageInstructionCount * sizeof(int32_t)) / sizeof(THDynamicPageEntryGroup);

typedef struct {
    union {
        struct {
            IMP redirectFunction;
            int32_t nextAvailableIndex;
        };
        
        int32_t placeholder[THDynamicPageInstructionCount];
    };
    
    THDynamicData dynamicData[THNumberOfDataPerPage];
} THDataPage;

typedef struct {
    int32_t fixedInstructions[THDynamicPageInstructionCount];
    THDynamicPageEntryGroup jumpInstructions[THNumberOfDataPerPage];
} THCodePage;

typedef struct {
    THDataPage dataPage;
    THCodePage codePage;
} THDynamicPage;

static THDynamicPage *THCreateDynamicePage()
{
    vm_address_t fixedPage = (vm_address_t)&th_dynamic_page;
    
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

@interface THDynamicPageAllocator()
@property (nonatomic, unsafe_unretained, readonly) IMP redirectFunction;
@property (nonatomic, strong) NSMutableArray *dynamicPages;
@end

@implementation THDynamicPageAllocator

- (instancetype)initWithRedirectFunction:(IMP)redirectFunction
{
    self = [super init];
    if (self) {
        _redirectFunction = redirectFunction;
    }
    return self;
}

- (IMP)allocateDynamicPageForFunction:(IMP)functionAdress
{
    if (!functionAdress) return NULL;
    
    THDynamicPage *dynamicPage = [self fetchCandidiateDynamicPage];

    if (!dynamicPage) return NULL;
    
    int slot = dynamicPage->dataPage.nextAvailableIndex;
    dynamicPage->dataPage.dynamicData[slot].originIMP = (IMP)functionAdress;
    dynamicPage->dataPage.nextAvailableIndex++;
    
    return (IMP)&dynamicPage->codePage.jumpInstructions[slot];
}

#pragma mark - Private
- (THDynamicPage *)fetchCandidiateDynamicPage
{
    THDynamicPage *reusablePage = [[self.dynamicPages lastObject] pointerValue];
    if (!reusablePage || reusablePage->dataPage.nextAvailableIndex == THNumberOfDataPerPage) {
        reusablePage = THCreateDynamicePage();
        if (!reusablePage) return NULL;

        [self.dynamicPages addObject:[NSValue valueWithPointer:reusablePage]];
    }
    
    reusablePage->dataPage.redirectFunction = self.redirectFunction;
    return reusablePage;
}

#pragma mark - Getter
- (NSMutableArray *)dynamicPages
{
    if (!_dynamicPages) {
        _dynamicPages = @[].mutableCopy;
    }
    return _dynamicPages;
}

@end
