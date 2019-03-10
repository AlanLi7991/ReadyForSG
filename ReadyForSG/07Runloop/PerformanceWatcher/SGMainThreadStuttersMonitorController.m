//
//  SGMainThreadStuttersMonitorController.m
//  ReadyForSG
//
//  Created by 郑森垚 on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGMainThreadStuttersMonitorController.h"
#import "ReadyForSG-Swift.h"
#import "SGObject.h"
#import "PerformanceWatcher.h"

@interface SGMainThreadStuttersMonitorController ()

@property (nonatomic, strong) SGActionRune *action;

@end

@implementation SGMainThreadStuttersMonitorController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [SGLogRune.instance attachWithView:self.view];
    _action = [[SGActionRune alloc] init];
    [_action attachWithViewController:self];
    __weak typeof(self) target = self;
    [_action.alert addAction:[UIAlertAction actionWithTitle:@"DoBusyJob" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [target doBusyJob];
    }]];
    
    [_action.alert addAction:[UIAlertAction actionWithTitle:@"ClearConsole" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SGLogRune.instance clearText];
    }]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[PerformanceWatcher sharedInstance] startMonitor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[PerformanceWatcher sharedInstance] stop];
}

+ (SGSampleRune *)rune {
    SGSampleRune *rune = [[SGSampleRune alloc] initWithController:self];
    rune.decription = @"Main Thread Monitor";
    return rune;
}

- (void)doBusyJob {
    [PerformanceWatcher sharedInstance]->printCallStacks = YES;
    for (int i = 0; i < 10000000; ++i) {
        @autoreleasepool {
            int a = 0;
            a++;
        }
    }
}

@end
