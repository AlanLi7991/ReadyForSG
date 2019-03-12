//
//  SGStaticParam.m
//  ReadyForSG
//
//  Created by Vince.Zheng on 2019/3/11.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGStaticParam.h"

static int staticGlobalVar = 10;

@interface SGStaticParam ()

@property (nonatomic, copy) void(^block)();

@end

@implementation SGStaticParam

- (void)captureStaticGlobalVar {
    self.block = ^() {
        int b = staticGlobalVar;
    };
}

@end
