//
//  SGSwizzleController.m
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGSwizzleController.h"
#import "ReadyForSG-Swift.h"
#import "SGObject.h"
#import "SGSwizzle.h"

@interface SGSwizzleController ()

@property (nonatomic, strong) SGActionRune *action;
@property (nonatomic, strong) SGSwizzle *swizzle;

@end

@implementation SGSwizzleController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [SGLogRune.instance attachWithView:self.view];
    _action = [[SGActionRune alloc] init];
    _swizzle = [[SGSwizzle alloc] init];
    [_action attachWithViewController:self];
    __weak typeof(self) target = self;
    [_action.alert addAction:[UIAlertAction actionWithTitle:@"Swizzling" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [target.swizzle swizzling];
    }]];
    [_action.alert addAction:[UIAlertAction actionWithTitle:@"CallOne" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [target.swizzle one];
    }]];
    [_action.alert addAction:[UIAlertAction actionWithTitle:@"CallTwo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [target.swizzle two];
    }]];
    
}


+ (SGSampleRune *)rune {
    SGSampleRune *rune = [[SGSampleRune alloc] initWithController:self];
    rune.decription = @"Object-C NSObject MessageForward";
    return rune;
}

@end
