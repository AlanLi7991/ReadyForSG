//
// Created by Elliot Li on 2019-03-07.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

#import "SGObject.h"
#import "objc/runtime.h"

#define DONT_CRASH (1)

@implementation SGObject

#if DONT_CRASH

//----------------------------------------------------------------------------//
#pragma mark - Crash 如何产生
//----------------------------------------------------------------------------//


/**
 * 如果方法结构体中
 * 1. objc_cache 未命中方法
 * 2. objc_method_list 未命中
 * 3. super_class 逐级未命中
 *
 * 该函数返回NO 进入消息转发
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    BOOL result = [super resolveInstanceMethod:sel];
    NSString *name = NSStringFromSelector(sel);
    NSLog(@"Object-C: [resolveInstanceMethod:] SEL %@ result %d", name, result);
    return result;
}

/**
 * 该方法去查询有没有备用接受者
 * 如果返回nil 或者 null 备用接收者就是自己（等于没有）
 *
 * 会再调用一次 resolveInstanceMethod
 *
 * 发现还是返回NO ，但是不影响去调用
 * 1. methodSignatureForSelector
 * 2. forwardInvocation
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    id result = [super forwardingTargetForSelector:aSelector];
    NSLog(@"Object-C: [forwardingTargetForSelector:] SEL %@ return %@ ", NSStringFromSelector(aSelector), result);
    if (aSelector == @selector(methodNotImplementation)) {
        return nil;
    }
    return result;
}

/**
 * 再此时进入OC-Runtime，值得注意的是 Swift 中是没有Runtime支持的这两个函数的
 * 1. 不存在NSMethodSignature、NSInvocation 这两个类
 * 2. NSObject 也不存在 methodSignatureForSelector、forwardInvocation 这两个函数
 *
 * 所谓 Signature 就是把Selector转化成C的char * 数组用来确定方法
 * 转化规则再 runtime.h 的 1732行 例如 #define _C_ID       '@'
 *
 * NSMethodSignature 感觉是对方法结构体 objc_method_t 的一个对象化（猜的）
 *
 * //----------------------------------------------------------------------------//
 *  如果这里返回 nil， 则直接会Crash，Crash就是这里产生的
 * //----------------------------------------------------------------------------//
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    NSLog(@"Object-C: [methodSignatureForSelector:] SEL %@ return %@ ", NSStringFromSelector(aSelector), result);
    if (result == nil) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return result;
}

/**
 * 有了 NSMethodSignature 可以实例化出来 NSInvocation
 * NSInvocation包含了
 * 1. 消息要发给谁 target
 * 2. SEL
 *
 * 然后去调用 methodForSelector 就可以找到具体的函数入口
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"Object-C: [forwardInvocation:] Invovation target %@ SEL %@",anInvocation.target, NSStringFromSelector(anInvocation.selector));
    [super forwardInvocation:anInvocation];
}

/**
 * 如果不存在这个消息 最终会调用 doesNotRecognizeSelector
 * Crash报的就是这个错误，但是不知道为什么不是Crash到这个函数里
 */
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"Object-C: [doesNotRecognizeSelector:]");
    return;
}

//----------------------------------------------------------------------------//
#pragma mark - SEL 如何找到函数入口 IMP
//----------------------------------------------------------------------------//

/**
 * 考点：IMP是什么
 *
 * 就是像定义Block一样
 *
 * typedef   id  _Nullable ( *IMP )( id  _Nonnull, SEL  _Nonnull, ...);
 * typedef 返回值 _Nullable (函数名)(参数1 _Nonnull, 参数2 _Nonnull, ...)
 *
 * 也就是说 *IMP = 函数名，* 取原文 object of 得到
 * object point to by IMP = 函数名，所以 IMP是某个函数的地址
 *
 * 考点: 如何通过SEL变成IMP
 *
 * 调用 methodForSelector 或者 runtime 的 class_getMethodImplementation
 *
 * 可以再一个Class的结构体里，通过SEL 再 objc_method_t 的结构体里查到， SEL相当于Key 值了
 *
 */

- (IMP)methodForSelector:(SEL)aSelector {
    return [super methodForSelector:aSelector];
}


#endif

@end
