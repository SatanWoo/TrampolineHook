//
//  THInterceptor.h
//  TrampolineHook
//
//  Created by z on 2020/4/25.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, THInterceptState) {
    THInterceptStateSuccess = 0,
    THInterceptStateFailed  = 1
};

@interface THInterceptorResult : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, unsafe_unretained, readonly) IMP replacedAddress;
@property (nonatomic, readonly)                    THInterceptState state;

@end

@interface THInterceptor : NSObject

+ (THInterceptor *)sharedInterceptorWithFunction:(IMP)redirectFunction;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, unsafe_unretained, readonly) IMP redirectFunction;

- (THInterceptorResult *)interceptFunction:(IMP)function;

@end

NS_ASSUME_NONNULL_END
