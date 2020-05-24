//
//  ViewController.m
//  MainThreadCheckerExample
//
//  Created by z on 2020/5/5.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "ViewController.h"
#import "MainThreadChecker/MTInitializer.h"
#import <TrampolineHook/THInterceptor.h>

@interface ViewController ()
@end

@implementation ViewController

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MTInitializer enableMainThreadChecker];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
