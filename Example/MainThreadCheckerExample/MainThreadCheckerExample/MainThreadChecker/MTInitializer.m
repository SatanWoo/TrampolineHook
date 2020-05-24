//
//  MTInitializer.m
//  TrampolineHook
//
//  Created by z on 2020/4/25.
//  Copyright © 2020 SatanWoo. All rights reserved.
//

#import "MTInitializer.h"
#import "THInterceptor.h"

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <dlfcn.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/objc.h>


#ifdef __LP64__
typedef struct mach_header_64 mt_macho_header;
#else
typedef struct mach_header mt_macho_header;
#endif

static void *MTGetDataSection(const struct mach_header *header, const char *sectname, size_t *bytes)
{
    void *data = getsectiondata((void *)header, "__DATA", sectname, bytes);
    if (!data) {
        data = getsectiondata((void *)header, "__DATA_CONST", sectname, bytes);
    }
    return data;
}

static void MTFindClassesToSwizzleInImage(const mt_macho_header *header, const char *binaryName, NSMutableArray *toSwizzleClasses)
{
    if (header == NULL) return;
    if (binaryName == NULL) return;
    
    unsigned long size = 0;
    unsigned int classCount = 0;
    
    Class *data = (Class *)MTGetDataSection(header, "__objc_classlist", &size);
    if (data == NULL) {
        data = objc_copyClassList(&classCount);
    } else {
        classCount = (unsigned int)(size / sizeof(void *));
    }
    
    for (unsigned int i = 0; i < classCount; i++) {
        Class cls = data[i];
        const char *className = class_getName(cls);
        const char *imageName = class_getImageName(cls);
        
        if (strncmp(className, "_", 1) == 0) continue;
        if (strcmp(imageName, binaryName) != 0) continue;
        
        BOOL isInheritedSubClass = NO;
        Class superCls = cls;
        while (superCls && superCls != [NSObject class]) {
            if (superCls == [UIView class]) {
                isInheritedSubClass = YES;
                break;
            }
            superCls = class_getSuperclass(superCls);
        }
        
        if (isInheritedSubClass) {
            [toSwizzleClasses addObject:cls];
        }
    }
}

static void MTMainThreadChecker(id obj, SEL selector) //
{
    if (![NSThread isMainThread]) {
        NSLog(@"[MTMainThreadChecker]::Found issue on %@ with selector %@", obj, NSStringFromSelector(selector));
    }
}

static bool MTAddSwizzler(Class cls, SEL selector)
{
    Method origMethod = class_getInstanceMethod(cls, selector);
    if (!origMethod) return false;
    
    IMP originIMP = method_getImplementation(origMethod);
    
    static THInterceptor *interceptor = nil;
    if (!interceptor) {
        interceptor = [[THInterceptor alloc] initWithRedirectionFunction:(IMP)MTMainThreadChecker];
    }
    
    if (!interceptor) return false;
    
    THInterceptorResult *result = [interceptor interceptFunction:originIMP];
    if (!result || result.state == THInterceptStateFailed) return false;
    
    method_setImplementation(origMethod, result.replacedAddress);
    
    return true;
}

@implementation MTInitializer

+ (void)enableMainThreadChecker
{    
    const char *UIKitImageName = class_getImageName([UIResponder class]);
    if (!UIKitImageName) {
        NSAssert(UIKitImageName != NULL, @"[MTInitializer]::Failed to find UIKItCore/UIKit binary");
        return;
    }

    uint32_t imageCount = _dyld_image_count();
    NSMutableArray *toSwizzleClasses = @[].mutableCopy;

    for (uint32_t idx = 0; idx < imageCount; idx++) {
        const char *binaryName = _dyld_get_image_name(idx);

        if (strcmp(binaryName, UIKitImageName) == 0) {
            const mt_macho_header *header = (const mt_macho_header *)_dyld_get_image_header(idx);
            MTFindClassesToSwizzleInImage(header, binaryName, toSwizzleClasses);
            break;
        }
    }

    // TODO: add webkit support
    // const char *webkitImageName = class_getImageName(NSClassFromString("WKWebView"));
    // if (webkitImageName) {}

    NSSet *ignoreList = [MTInitializer MTIgnoreSwizzleList];

    for (Class cls in toSwizzleClasses) {
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(cls, &methodCount);

        for (unsigned int i = 0; i < methodCount; i++) {
            Method m = *(methods + i);
            SEL sel = method_getName(m);

            NSString *selName = NSStringFromSelector(sel);

            if ([ignoreList containsObject:selName]) continue;

            if ([selName hasPrefix:@"nsli_"] ||
                [selName hasPrefix:@"nsis_"]) {
                continue;;
            }

            bool ret = MTAddSwizzler(cls, sel);
            if (!ret) {
                NSAssert(ret, @"[MTInitializer]:: Add swizzler failed %@ %@", NSStringFromClass(cls), selName);
            }
        }

        free(methods);
        methods = NULL;
    }
}

+ (NSSet *)MTIgnoreSwizzleList
{
    static dispatch_once_t onceToken;
    static NSSet *ignoreList;
    dispatch_once(&onceToken, ^{
        NSArray *lists = @[
            /*UIViewController的:*/
            @".cxx_destruct",
            @"dealloc",
            @"_isDeallocating",
            @"release",
            @"autorelease",
            @"retain",
            @"Retain",
            @"_tryRetain",
            @"copy",
            /*UIView的:*/
            @"nsis_descriptionOfVariable:",
            /*NSObject的:*/
            @"respondsToSelector:",
            @"class",
            @"methodSignatureForSelector:",
            @"allowsWeakReference",
            @"retainWeakReference",
            @"init",
            @"forwardInvocation:",
            @"description",
            @"debugDescription",
            @"self",
            @"beginBackgroundTaskWithExpirationHandler:",
            @"beginBackgroundTaskWithName:expirationHandler:",
            @"endBackgroundTask:",
            @"lockFocus",
            @"lockFocusIfCanDraw",
            @"lockFocusIfCanDraw"
        ];
        
        ignoreList = [NSSet setWithArray:lists];
    });
    return ignoreList;
}

@end
