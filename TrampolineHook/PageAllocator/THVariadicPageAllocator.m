//
//  THDynamicPageVariadicAllocator.m
//  TrampolineHook
//
//  Created by z on 2020/5/18.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "THVariadicPageAllocator.h"
#import "THPageDefinition.h"

FOUNDATION_EXTERN id th_dynamic_page_var(id, SEL);

#if defined(__arm64__)
#import "THPageDefinition_arm64.h"
#import "THPageVariadicContext_arm64.h"
static const int32_t THDynamicPageVaradicInstructionCount = 10;
#else
#error x86_64 & arm64e to be supported
#endif

static const size_t THNumberOfDataPerVariadicPage = (THPageSize - THDynamicPageVaradicInstructionCount * sizeof(int32_t)) / sizeof(THDynamicPageEntryGroup);

typedef struct {
    union {
        struct {
            IMP redirectFunction;
            IMP preFunction;
            IMP postFunction;
            int32_t nextAvailableIndex;
        };
        
        int32_t placeholder[THDynamicPageVaradicInstructionCount];
    };
    
    THDynamicData dynamicData[THNumberOfDataPerVariadicPage];
} THVariadicDataPage;

typedef struct {
    int32_t fixedInstructions[THDynamicPageVaradicInstructionCount];
    THDynamicPageEntryGroup jumpInstructions[THNumberOfDataPerVariadicPage];
} THVariadicCodePage;

typedef struct {
    THVariadicDataPage dataPage;
    THVariadicCodePage codePage;
} THVariadicDynamicPage;

@interface THVariadicPageAllocator()
@property (nonatomic, unsafe_unretained, readonly) IMP preFunction;
@property (nonatomic, unsafe_unretained, readonly) IMP postFunction;
@end

@implementation THVariadicPageAllocator

- (instancetype)initWithRedirectionFunction:(IMP)redirectFunction
{
    self = [super initWithRedirectionFunction:redirectFunction];
    if (self) {
        _preFunction = (IMP)THPageVariadicContextPre;
        _postFunction = (IMP)THPageVariadicContextPost;
    }
    return self;
}

- (void)configurePageLayoutForNewPage:(void *)newPage
{
    if (!newPage) return;
    
    THVariadicDynamicPage *page = (THVariadicDynamicPage *)newPage;
    page->dataPage.redirectFunction = self.redirectFunction;
    page->dataPage.preFunction = self.preFunction;
    page->dataPage.postFunction = self.postFunction;
}

- (BOOL)isValidReusablePage:(void *)resuablePage
{
    if (!resuablePage) return FALSE;
    
    THVariadicDynamicPage *page = (THVariadicDynamicPage *)resuablePage;
    if (page->dataPage.nextAvailableIndex == THNumberOfDataPerVariadicPage) return FALSE;
    return YES;
}

- (void *)templatePageAddress
{
    return &th_dynamic_page_var;
}

- (IMP)replaceAddress:(IMP)functionAddress inPage:(void *)page
{
    if (!page) return NULL;
    
    THVariadicDynamicPage *dynamicPage = (THVariadicDynamicPage *)page;
    
    int slot = dynamicPage->dataPage.nextAvailableIndex;
    dynamicPage->dataPage.dynamicData[slot].originIMP = (IMP)functionAddress;
    dynamicPage->dataPage.nextAvailableIndex++;

    return (IMP)&dynamicPage->codePage.jumpInstructions[slot];
}

@end
