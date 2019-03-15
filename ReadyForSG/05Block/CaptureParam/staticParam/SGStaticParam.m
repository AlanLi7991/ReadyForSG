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

@property (nonatomic, copy) void(^block)();

@end

@implementation SGStaticParam

// 使用以下的命令，即可完成OC转C++
// xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc SGStaticParam.m -o SGStaticParam-arm64.cpp
- (void)captureStaticGlobalVar {
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
    
    self.block = ^() {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
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
#pragma clang diagostic pop
    };
}

@end
