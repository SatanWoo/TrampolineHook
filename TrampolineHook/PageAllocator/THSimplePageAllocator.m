//
//  THDynamicAllocator.m
//  TrampolineHook
//
//  Created by z on 2020/4/25.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "THSimplePageAllocator.h"
#import "THPageDefinition.h"

FOUNDATION_EXTERN id th_dynamic_page(id, SEL);

#if defined(__arm64__)
#import "THPageDefinition_arm64.h"
static const int32_t THSimplePageInstructionCount = 32;
#else
#error x86_64 & arm64e to be supported
#endif

static const size_t THNumberOfDataPerSimplePage = (THPageSize - THSimplePageInstructionCount * sizeof(int32_t)) / sizeof(THDynamicPageEntryGroup);

typedef struct {
    union {
        struct {
            IMP redirectFunction;
            int32_t nextAvailableIndex;
        };
        
        int32_t placeholder[THSimplePageInstructionCount];
    };
    
    THDynamicData dynamicData[THNumberOfDataPerSimplePage];
} THDataPage;

typedef struct {
    int32_t fixedInstructions[THSimplePageInstructionCount];
    THDynamicPageEntryGroup jumpInstructions[THNumberOfDataPerSimplePage];
} THCodePage;

typedef struct {
    THDataPage dataPage;
    THCodePage codePage;
} THDynamicPage;


@implementation THSimplePageAllocator

- (void)configurePageLayoutForNewPage:(void *)newPage
{
    if (!newPage) return;
    
    THDynamicPage *page = (THDynamicPage *)newPage;
    page->dataPage.redirectFunction = self.redirectFunction;
}

- (BOOL)isValidReusablePage:(void *)resuablePage
{
    if (!resuablePage) return FALSE;
    
    THDynamicPage *page = (THDynamicPage *)resuablePage;
    if (page->dataPage.nextAvailableIndex == THNumberOfDataPerSimplePage) return FALSE;
    return YES;
}

- (void *)templatePageAddress
{
    return &th_dynamic_page;
}

- (IMP)replaceAddress:(IMP)functionAddress inPage:(void *)page
{
    if (!page) return NULL;
    
    THDynamicPage *dynamicPage = (THDynamicPage *)page;
    
    int slot = dynamicPage->dataPage.nextAvailableIndex;
    dynamicPage->dataPage.dynamicData[slot].originIMP = (IMP)functionAddress;
    dynamicPage->dataPage.nextAvailableIndex++;

    return (IMP)&dynamicPage->codePage.jumpInstructions[slot];
}


@end
