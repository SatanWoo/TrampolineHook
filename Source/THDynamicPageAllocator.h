//
//  THDynamicAllocator.h
//  TrampolineHook
//
//  Created by z on 2020/4/25.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface THDynamicPageAllocator : NSObject

- (instancetype)initWithRedirectFunction:(IMP)redirectFunction;
- (IMP)allocateDynamicPageForFunction:(IMP)functionAdress;

@end

NS_ASSUME_NONNULL_END
