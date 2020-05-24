//
//  THDynamicAllocatorProtocol.h
//  TrampolineHook
//
//  Created by z on 2020/5/18.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#ifndef THDynamicAllocatorProtocol_h
#define THDynamicAllocatorProtocol_h
#import <Foundation/Foundation.h>

@protocol THDynamicAllocatable <NSObject>
@required

- (instancetype)initWithRedirectionFunction:(IMP)redirectFunction;
- (IMP)allocateDynamicPageForFunction:(IMP)functionAdress;

@end


#endif /* THDynamicAllocatorProtocol_h */
