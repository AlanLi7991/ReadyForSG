//
// Created by Elliot Li on 2019-03-08.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

#import "SGMessageController.h"
#import "ReadyForSG-Swift.h"
#import "SGObject.h"


@interface SGMessageController ()

@property (nonatomic, strong) SGActionRune *action;
@property (nonatomic, strong) SGObject *obj;

@end

@implementation SGMessageController {

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [SGLogRune.instance attachWithView:self.view];
    _action = [[SGActionRune alloc] init];
    _obj = [[SGObject alloc] init];
    [_action attachWithViewController:self];
    __weak typeof(self) target = self;
    [_action.alert addAction:[UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [target.obj test];
    }]];
    
}


+ (SGSampleRune *)rune {
    SGSampleRune *rune = [[SGSampleRune alloc] initWithController:self];
    rune.decription = @"NSObject MessageForward log";
    return rune;
}

@end
