//
//  ReadyForWX.m
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "ReadyForWX.h"
#import "ReadyForSG-Swift.h"

@implementation ReadyForWX


+ (SGSampleRune *)rune {
    return [[SGSampleRune alloc] initWithTitle:@"ReadyForWX" controller:self];
}

+ (SGSampleRunes *)runes {
    return [[SGSampleRunes alloc] initWithTitle:@"OC-Example"];
}

@end
