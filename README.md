# TrampolineHook
**A solution for centralized method redirection.**

You can read articles about underlying implementation of this project.

1. [基于桥的全量方法Hook方案 - 探究苹果主线程检查实现](http://satanwoo.github.io/2017/09/24/mainthreadchecker1/)
2. [基于桥的全量方法 Hook 方案（2） - 全新升级](http://satanwoo.github.io/2020/04/22/NewBridgeHook/)
3. [基于桥的全量方法 Hook 方案（3）- 开源 TrampolineHook](http://satanwoo.github.io/2020/04/26/TrampolineHookOpenSource/)


## 1. Usage

The interface of TrampolineHook is very very simple. Only two steps are required.

1. Create the global interceptor with your centralized function as follows:

```
// Suppose you have  function defined as

// C Format
void myInterceptor
{
    // bla bla bla
}

// Create the inteceptor with your interceptor function
THInterceptor *interceptor = [[THInterceptor alloc] initWithRedirectionFunction:(IMP)myInterceptor];
```

2. Intercept any function you want no matter what the method signature it is.

``` 
// Suppose you want to intercept the call of - [UIView initWithFrame:]
Method m = class_getInstanceMethod([UIView class], @selector(initWithFrame:));
IMP imp = method_getImplementation(m);

// Intercept the imp
THInterceptorResult *result = [interceptor interceptFunction:imp];

// You can check the result.state to find whether the inteception is successfully carried out or not.
result.state == THInterceptStateSuccess
```



## 2. How to debug

The debug of interception is not very easy. 

**Remember always use the `result.replacedAddress` returned from `interceptFunction` for breakpoint.**



## 3. Example
There is one typical example associated with this open source project called **MainThreadChecker**。It is the rewritten version of the implementation in **Apple libMainThreadChecker.dylib**

It is almost the same as the one of Apple based on my own reverse engineering. **No Private APIs used.** 

The usage of MainThreadChecker is quite easy.

```
+ (void)load 
{
    [MTInitializer enableMainThreadChecker]
}
```



## 4. TODO

- [x] API Stability. 
- [x] Varadic Argument Interceptor.
- [ ] More examples.
- [ ] Performance Benchmark.

You can view the **Project** tab to follow the process of this project.



## 5.Reference

The great works listed below inspired me a lot during the development of **TrampolineHook**.

- [Dobby](https://github.com/jmpews/Dobby) @jmpews




## 6. License

Copyright 2020 @SatanWoo

Checkout [License](https://github.com/SatanWoo/TrampolineHook/blob/master/LICENSE)
