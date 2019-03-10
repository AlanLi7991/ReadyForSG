//
//  PerformanceWatcher.h
//  ReadyForSG
//
//  Created by 郑森垚 on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PerformanceWatcher : NSObject
{
@public
    dispatch_semaphore_t semaphore;
    CFRunLoopActivity lastTimeoutActivity;
    int timeoutCount;
    NSArray *callStacks;
}

+ (instancetype)sharedInstance;

- (void)startMonitor;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
