//
//  SSAutoreleasingTest.m
//  ReadyForSG
//
//  Created by Vince.Zheng on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SSAutoreleasingTest.h"

@implementation SSAutoreleasingTest

- (void)testAutoreleasing {
    __unsafe_unretained NSObject *obj = nil;
    {
        __autoreleasing NSObject *b = [[NSObject alloc] init];
        obj = b;
    }
    NSLog(@"%@", obj);
}

@end
