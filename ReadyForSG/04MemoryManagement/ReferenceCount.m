//
//  ReferenceCount.m
//  ReadyForSG
//
//  Created by 三杜 on 2019/3/21.
//  Copyright © 2019年 Alanli7991. All rights reserved.
//

#import "ReferenceCount.h"

@implementation ReferenceCount

- (void)taggedPointer {
    NSNumber *num1 = @1;
    NSNumber *num2 = @2;
    NSNumber *numf = @(0xFFFF);
    
    NSLog(@"pointer of num1 is %p", num1);
    NSLog(@"pointer of num2 is %p", num2);
    NSLog(@"pointer of numf is %p", numf);
}

@end
