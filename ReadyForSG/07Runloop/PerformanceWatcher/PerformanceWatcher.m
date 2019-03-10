//
//  PerformanceWatcher.m
//  ReadyForSG
//
//  Created by 郑森垚 on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "PerformanceWatcher.h"
#include <signal.h>
#include <pthread.h>

void RunloopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    PerformanceWatcher *monitor = (__bridge PerformanceWatcher *)info;
    monitor->callStacks = [NSThread callStackSymbols];

    monitor->lastTimeoutActivity = activity;
    dispatch_semaphore_signal(monitor->semaphore);
}

void USR1SignalHandler(int signal)
{
    if (signal != SIGUSR1) {
        return;
    }
    NSArray* callStackSymbols = [NSThread callStackSymbols];
    NSLog(@"call stack symbols:");
    NSLog(@"%@", callStackSymbols);
}

void InstallSignalHandler()
{
    signal(SIGUSR1, USR1SignalHandler);
}

@interface PerformanceWatcher ()
{
    CFRunLoopObserverRef observer;
    pthread_t            mainThreadID;
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
    if ([NSThread isMainThread] == NO) {
        NSLog(@"Error: startWatch must be called from main thread!");
        return;
    }
    
    if (observer) {
        return;
    }
    
    //注册handler
    InstallSignalHandler();
    mainThreadID = pthread_self();

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
                    NSLog(@"Main thread timeout count reaches three");
//                    NSLog(@"%@", self->callStacks);
//                    NSLog(@"这里捕获到的堆栈，是卡顿运行前的堆栈，如果要捕获卡顿时的堆栈，可以使用信号的方式");
                    pthread_kill(self->mainThreadID, SIGUSR1);
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
