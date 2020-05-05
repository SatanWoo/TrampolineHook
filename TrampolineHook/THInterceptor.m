//
//  THInterceptor.m
//  TrampolineHook
//
//  Created by z on 2020/4/25.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "THInterceptor.h"
#import "THDynamicPageAllocator.h"

#define THInterceptorResultFail \
        [[THInterceptorResult alloc] initWithReplacedAddress:NULL state:THInterceptStateFailed]

@implementation THInterceptorResult

- (instancetype)initWithReplacedAddress:(IMP)address state:(THInterceptState)state
{
    self = [super init];
    if (self) {
        _replacedAddress = address;
        _state = state;
    }
    return self;
}

@end

@interface THInterceptor()
@property (nonatomic, strong) THDynamicPageAllocator *pageAllactor;
@property (nonatomic, unsafe_unretained, readwrite) IMP redirectFunction;
@end

@implementation THInterceptor

+ (THInterceptor *)sharedInterceptorWithFunction:(IMP)redirectFunction
{
    NSAssert(redirectFunction != NULL, @"[THInterceptor]::Interceptor must be created with non-null redirect function");
    
    static dispatch_once_t onceToken;
    static THInterceptor *_interceptor;
    dispatch_once(&onceToken, ^{
        _interceptor = [[THInterceptor alloc] initWithRedirectFunction:redirectFunction];
    });
    return _interceptor;
}

- (instancetype)initWithRedirectFunction:(IMP)redirectFunction
{
    self = [super init];
    if (self) {
        _redirectFunction = redirectFunction;
    }
    return self;
}

#pragma mark - Public API
- (THInterceptorResult *)interceptFunction:(IMP)function
{
    if (function == NULL) return THInterceptorResultFail;
    
    IMP jumpAddress = [self.pageAllactor allocateDynamicPageForFunction:function];
    if (!jumpAddress) {
        NSAssert(jumpAddress != NULL, @"[THInterceptor]::Allocate dynamic page failed");
        return THInterceptorResultFail;
    }
    
    return [[THInterceptorResult alloc] initWithReplacedAddress:jumpAddress
                                                          state:THInterceptStateSuccess];
}

#pragma mark - Getter

- (THDynamicPageAllocator *)pageAllactor
{
    if (!_pageAllactor) {
        _pageAllactor = [[THDynamicPageAllocator alloc] initWithRedirectFunction:self.redirectFunction];
    }
    return _pageAllactor;
}

@end
