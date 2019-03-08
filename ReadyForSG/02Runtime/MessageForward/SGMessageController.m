//
// Created by Elliot Li on 2019-03-08.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

#import "SGMessageController.h"
#import "ReadyForSG-Swift.h"


@implementation SGMessageController {

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}


+ (SGSampleRune *)rune {
    SGSampleRune *rune = [[SGSampleRune alloc] initWithController:self];
    rune.decription = @"NSObject MessageForward log";
    return rune;
}

@end