//
//  SGBlockType.m
//  ReadyForSG
//
//  Created by Vince.Zheng on 2019/3/17.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGBlockType.h"

static NSObject *staticGlobalObj = nil;

@interface SGBlockType ()

@property (nonatomic, copy) void (^heapBlock)(void);

@end

@implementation SGBlockType

- (void)testAllBlock {
    staticGlobalObj = [[NSObject alloc] init];
    
    [self testStackBlock];
    [self testGlobalBlock];
}

- (void)testStackBlock {
    NSLog(@"start %s:%d", __FUNCTION__, __LINE__);
    int localVariableInt = 1;
    NSObject *localVariableObj = [[NSObject alloc] init];
    __block int blockModifierLocalVarInt = 2;
    __block NSObject *blockModifierLocalVarObj = [[NSObject alloc] init];
    NSLog(@"localVariableObj retainCount: %ld", (long)CFGetRetainCount((__bridge CFTypeRef)(localVariableObj)));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
    
    // 默认修饰符是__strong，所以stackBlock会变成『堆block』
    __weak void (^stackBlock)(void) = ^() {
        int a = localVariableInt;
        int b = blockModifierLocalVarInt;
        NSObject *c = blockModifierLocalVarObj;
        NSLog(@"internal localVariableObj retainCount: %ld", (long)CFGetRetainCount((__bridge CFTypeRef)(localVariableObj)));
    };
    
    stackBlock();
    void (^copyStackBlock)(void) = [stackBlock copy];
    NSLog(@"stackBlock: %@ retainCount: %ld", [stackBlock class], (long)CFGetRetainCount((__bridge CFTypeRef)(stackBlock)));
    copyStackBlock();
    NSLog(@"copyStackBlock: %@ retainCount: %ld", [copyStackBlock class], (long)CFGetRetainCount((__bridge CFTypeRef)(copyStackBlock)));
    
    self.heapBlock = [copyStackBlock copy];
    NSLog(@"heapBlock: %@ retainCount: %ld", [self.heapBlock class], (long)CFGetRetainCount((__bridge CFTypeRef)self.heapBlock));
    self.heapBlock();
    
#pragma clang diagnostic pop
    
    NSLog(@"end %s:%d", __FUNCTION__, __LINE__);
}

- (void)testGlobalBlock {
    NSLog(@"start global block");
    NSLog(@"global variable retainCount: %ld", (long)CFGetRetainCount((__bridge CFTypeRef)(staticGlobalObj)));
    
    void (^globalBlock)(void) = ^() {
        NSLog(@"internal global variable retainCount: %ld", (long)CFGetRetainCount((__bridge CFTypeRef)(staticGlobalObj)));
    };
    
    globalBlock();
    NSLog(@"globalBlock: %@ retainCount: %ld", [globalBlock class], (long)CFGetRetainCount((__bridge CFTypeRef)(globalBlock)));
    void (^copyGlobalBlock)(void) = [globalBlock copy];
    copyGlobalBlock();
    NSLog(@"copyGlobalBlock: %@ retainCount: %ld", [copyGlobalBlock class], (long)CFGetRetainCount((__bridge CFTypeRef)(copyGlobalBlock)));
}

@end
