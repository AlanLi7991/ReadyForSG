//
//  SGStaticParam.m
//  ReadyForSG
//
//  Created by Vince.Zheng on 2019/3/11.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGStaticParam.h"

// 静态全局变量
static int staticGlobalVarInt = 10;
static NSObject* staticGlobalVarObj = nil;

// 全局变量
int globalVarInt = 2;
NSObject *globalVarObj = nil;

@interface SGStaticParam ()

@property (nonatomic, copy) void(^memberCopyVar)(void);

@end

@implementation SGStaticParam

- (void)swap:(int *)a b:(int *)b {
    int temp = *a;
    *a = *b;
    *b = temp;
}

typedef struct {
    int a;
} A;

// 使用以下的命令，即可完成OC转C++
// xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fblocks -fobjc-runtime=ios-9.0.0 -stdlib=libc++ SGStaticParam.m
- (void)captureStaticGlobalVar {
    int a = 1;
    int b = 2;
    A *aa = (A *)malloc(sizeof(A));
    [self swap:aa b:&b];
    
    // 静态全局变量
    staticGlobalVarObj = [[NSObject alloc] init];
    
    // 全局变量
    globalVarObj = [[NSObject alloc] init];
    
    // 静态局部变量
    static int staticLocalVariableInt = 1;
    static NSObject *staticLocalVariableObj = nil;
    staticLocalVariableObj = [[NSObject alloc] init];
    
    // 局部变量
    int localVariableInt = 1;
    NSObject *localVariableObj = [[NSObject alloc] init];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    // 去掉警告：不安全的指针赋值
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
    
    __weak NSObject *weakLocalParamPtr = [[NSObject alloc] init];
    
    __block int blockModifierInt = 1;
    __block NSObject *blockModifierObj = [[NSObject alloc] init];
    __block NSObject *obj3 = self.description;
    
//    __weak void (^tempBlock)(void) = ^() {
    void (^tempBlock)(void) = ^() {
        // 全局变量
        int g = globalVarInt;
        NSObject *h = globalVarObj;
        
        // 静态全局变量
        int a = staticGlobalVarInt;
        NSObject *f = staticGlobalVarObj;
        
        // 静态局部变量
        int b = staticLocalVariableInt;
        NSObject *c = staticLocalVariableObj;
        
        // 局部变量
        int d = localVariableInt;
        NSObject *e = localVariableObj;
        
        // 所有权局部变量指针
        NSObject *i = weakLocalParamPtr;
        
        // block修饰符
        blockModifierInt += 1;
        [blockModifierObj copy];
    };
    
    void (^tempBlock2)(void) = ^() {
        blockModifierInt+=1;
    };
    // 全局Block (_NSConcreteGlobalBlock)：引用的是，全局变量，全局静态变量，静态变量
    // 栈区Block (_NSConcreteStackBlock)：引用局部变量，而又没被copy，strong的block
    // 堆区Block（_NSConcreteMallocBlock）：引用局部变量，被copy，strong的block
    self.memberCopyVar = tempBlock;
    self.memberCopyVar();
    
#pragma clang diagostic pop
}

@end
