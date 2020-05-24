//
//  THPageAllocator.h
//  TrampolineHook
//
//  Created by z on 2020/5/19.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THDynamicAllocatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface THPageAllocator : NSObject <THDynamicAllocatable>
@property (nonatomic, unsafe_unretained, readonly) IMP redirectFunction;

- (void)configurePageLayoutForNewPage:(void *)newPage;
- (BOOL)isValidReusablePage:(void *)resuablePage;
- (void *)templatePageAddress;
- (IMP)replaceAddress:(IMP)functionAddress inPage:(void *)page;

@end

NS_ASSUME_NONNULL_END
