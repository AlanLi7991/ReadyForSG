//
//  SGSwizzle.m
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGSwizzle.h"
#import "objc/runtime.h"



@implementation SGSwizzle

- (void)swizzling {

    SEL selector_one = @selector(one);
    SEL selector_two = @selector(two);
    Method method_one = class_getInstanceMethod(SGSwizzle.class, selector_one);
    Method method_two = class_getInstanceMethod(SGSwizzle.class, selector_two);

    method_exchangeImplementations(method_one, method_two);

    NSLog(@"SGSwizzle swizzling");
}
- (void)one {
    NSLog(@"SGSwizzle invoke method one");
}

- (void)two {
    NSLog(@"SGSwizzle invoke method two");
}

@end
