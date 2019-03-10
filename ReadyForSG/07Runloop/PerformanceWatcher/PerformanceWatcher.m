//
//  PerformanceWatcher.m
//  ReadyForSG
//
//  Created by 郑森垚 on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "PerformanceWatcher.h"

void RunloopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    PerformanceWatcher *monitor = (__bridge PerformanceWatcher *)info;
    if (monitor->printCallStacks) {
        NSLog(@"stacks:");
        NSLog(@"%@", [NSThread callStackSymbols]);
    }

    monitor->lastTimeoutActivity = activity;
    dispatch_semaphore_signal(monitor->semaphore);
}

@interface PerformanceWatcher ()
{
    CFRunLoopObserverRef observer;
}

@end

@implementation PerformanceWatcher

+ (instancetype)sharedInstance {
    static PerformanceWatcher *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PerformanceWatcher new];
    });
    
    return instance;
}

- (void)startMonitor {
    if (observer) {
        return;
    }
    
    // 创建信号
    semaphore = dispatch_semaphore_create(0);
    timeoutCount = 0;

    //1. observer
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, RunloopObserverCallback, &context);
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES) {
            long st = dispatch_semaphore_wait(self->semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 30));
            if (st != 0) {
                //timeout
                if (!self->observer) {
                    self->semaphore = 0;
                    self->lastTimeoutActivity = 0;
                    self->timeoutCount = 0;
                    return;
                }
                
                if (self->lastTimeoutActivity == kCFRunLoopBeforeSources
                    || self->lastTimeoutActivity == kCFRunLoopAfterWaiting) {
                    if (++self->timeoutCount < 4) {
                        continue;
                    }
                    self->printCallStacks = NO;
                    NSLog(@"Main thread timeout count reaches three");
                }
            }
            
            self->timeoutCount = 0;
        }
    });
}

- (void)stop {
    if (observer) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        CFRelease(observer);
        observer = NULL;
    }
}

@end
