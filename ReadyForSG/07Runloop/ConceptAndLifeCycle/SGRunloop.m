//
//  SGRunloop.m
//  ReadyForSG
//
//  Created by 郑森垚 on 2019/3/7.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGRunloop.h"

@implementation SGRunloop

@end

//----------------------------------------------------------------------------//
#pragma mark - Runloop Concept
//----------------------------------------------------------------------------//

/**
 * Runloop是用来处理事件和消息的一种机制，跟一个线程绑定，使得线程可以处于
 * “等待消息->接受消息->处理消息“的循环中，从而达到在没有消息到来的情况下休
 * 眠以避免系统资源的占有，消息一到来立刻恢复的目的。runloop实际上就是一个
 * while循环，只不过这个while循环，一是可以在线程不使用时暂时休眠，不占用
 * 系统资源，这是依靠系统内核实现的；二是可以接受各种事件来唤醒线程。
 *
 * 苹果官网文档：
 * https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW23
 *
 * 一篇讲得比较全面的文章：
 * http://weslyxl.coding.me/2018/03/18/2018/3/RunLoop从源码到应用全面解析/
 *
 * Mark:
 * 1. Runloop有C、OC和swift三套API，C语言的API是线程安全的，OC的API是非线程安全的。
 * 使用OC接口在某个线程中使用另一个线程的NSRunloop对象，可能出现奇怪的现象。
 * 2. Runloop不能自己创建，因为它跟线程绑定，可以在线程中获取到它。
 * 3. App启动时，主线程就处于Runloop中。其他线程需要其他启动Runloop
 */

//----------------------------------------------------------------------------//
#pragma mark - Runloop Mode
//----------------------------------------------------------------------------//
/**
 *         (contains)               (contains)
 * Runloop ----------> Mode(一对多) ----------> Source（Set）、Observer（Array）、Timer（Array）
 * Mark:
 * 1. 一个Runloop可以有多个Modes，但同一时间只能运行在某个Mode。如果要切换某一个Mode，
 *    必须先退出当前Mode，再以另一个Mode进入runloop。
 * 2. 某个Source、Observer或者Timer可以在多个Mode中注册，但只有runloop当前Mode下的
 *    Source、Observer或者Timer才可以生效
 *
 * 常用Mode：
 * 1. kCFRunLoopDefaultMode：创建一个Runloop时的默认Mode，除了屏幕滑动，一般情况下都处于该Mode
 * 2. UITrackingRunLoopMode：屏幕滑动时处于该Mode，如滑动tableview
 * 3. kCFRunLoopCommonMode：该Mode实际上只是一种标记，当Mode切换时，该Mode的Source、
 *    Observer和Timer会自动同步到当前运行的Mode中。这也是NSTimer在添加到runloop中的时
 *    候，要用NSRunLoopCommonModes作为参数的原因
 * 4. GSEventReceiveRunLoopMode：接受系统事件的内部Mode，通常用不到
 */


//----------------------------------------------------------------------------//
#pragma mark - Runloop Source
//----------------------------------------------------------------------------//
/**
 * Runloop的Source可以自定义，苹果默认定义了两种实现，Source0和Source1。
 * 1. Source0负责App内部事件，由App管理触发，如UITouch事件，这类Source需要手动触发唤醒Runloop
 * 2. Source1是基于Port的，除了包含回调指针外还包含一个mach port。不同于Source0，
 *    Source1可以监听系统端口和其他线程通信，它能够主动唤醒Runloop
 */


//----------------------------------------------------------------------------//
#pragma mark - Runloop Observer Activities
//----------------------------------------------------------------------------//
/**
     typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
     kCFRunLoopEntry = (1UL << 0), // 进入RunLoop
     kCFRunLoopBeforeTimers = (1UL << 1), // 即将开始Timer处理
     kCFRunLoopBeforeSources = (1UL << 2), // 即将开始Source处理
     kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
     kCFRunLoopAfterWaiting = (1UL << 6), //从休眠状态唤醒
     kCFRunLoopExit = (1UL << 7), //退出RunLoop
     kCFRunLoopAllActivities = 0x0FFFFFFFU
     };
*/

//----------------------------------------------------------------------------//
#pragma mark - Runloop Timer
//----------------------------------------------------------------------------//
/**
 * Runloop中的Timer，实际上其上层就是NSTimer。它跟Source1一样，也是基于Port的。
 * 只不过，所有Timer公用一个Port，Mode Timer Port。因此，Timer不需要手动触发就能唤醒Runloop。
 *
 * Mark:
 * 1. 使用NSTimer之前必须注册到Runloop中，但是RunLoop为了节省资源，
 *    并不会在非常准确的时间点调用定时器，如果一个任务执行时间较长，那
 *    么当错过一个时间点后只能等到下一个时间点执行
 * 2. NSTimer有两种创建方式，timerWithXXX和scheduleTimerWithXXX，
 *    两者的区别在于后者除了创建一个timer之外还会自动以kCFRunLoopDefaultMode的
 *    mode添加到当前线程的runloop中
 * 3. 使用scheduleTimerWithXXX的接口创建的timer，在屏幕滑动时，timer是不会正常工作的
 * 4. 如果在一个子线程中add一个timer，但是子线程本身的runloop没有启动，timer是不会工作的
 */


//----------------------------------------------------------------------------//
#pragma mark - Runloop Cycle
//----------------------------------------------------------------------------//
/**
 * 1. 通知Observer即将进入Runloop（kCFRunLoopEntry）
 *                   Cycle Start
 * ------------------------------------------------
 * 2. 通知observer即将处理timer（kCFRunLoopBeforeTimers）
 * 3. 通知observer即将处理source0（kCFRunLoopBeforeSources）
 * 4. 处理非延迟的主线程调用
 * 5. 处理source0事件
 * 6. 判断是否存在source1，若存在source1，直接跳到第10步
 * 7. 通知observer即将进入休眠状态（kCFRunLoopBeforeWaiting）
 * 8. 有事件唤醒runloop，如source0手动触发、source1主动唤醒、
      timer主动唤醒、dispatch_main_queue唤醒
 *    a. An event arrives for a port-based input source.
 *    b. A timer fires.
 *    c. The timeout value set for the run loop expires.
 *    d. The run loop is explicitly woken up.
 * 9. 通知observer即将被唤醒（kCFRunLoopAfterWaiting）
 * 10.
 *    a. 若是timer唤醒，处理timer事件
 *    b. 否则若是main dispatch唤醒，处理main dispatch
 *    c. 否则处理source1事件
 * 11. 若发生下面四个条件中的一条，则退出runloop（直接到12），否则跳到第2步
 *    a. 进入loop时参数说明loop执行完就返回
 *    b. 超出传入参数的超时时间了
 *    c. 被外部调用者停掉了
 *    d. 没有任何source、timer了（网上把observer也包括了，应该是错的）
 * 12. 通知observer即将退出runloop（kCFRunLoopExit）
 */

//----------------------------------------------------------------------------//
#pragma mark - 考点 AutoreleasePool与Runloop
//----------------------------------------------------------------------------//
/**
 * 1. App启动后，苹果在主线程注册了两个Observer，回调都是_wrapRunLoopWithAutoreleasePoolHandler()
 * 2. 第一个observer监听的事件是enter，其回调内会调用_objc_autoreleasePoolPush()创建
 *    自动释放池，order是-2147483647，优先级最高，保证创建释放池发生在其他所有回调之前。
 * 3. 第二个observer监听了两个事件：
 *    a. BeforeWaiting：调用_objc_autoreleasePoolPop() 和 _objc_autoreleasePoolPush()，
 *       释放旧的池并创建新池。
 *    b. Exit：调用 _objc_autoreleasePoolPop() 来释放自动释放池。这个observer的order
 *       是2147483647，优先级最低，保证其释放池子发生在其他所有回调之后。
 *
 * Mark: When to use @autoReleasePool
 * 1. Use Local Autorelease Pool Blocks to Reduce Peak Memory Footprint
 * 2. If you are writing a Foundation-only program or if you detach a thread,
 *    you need to create your own autorelease pool block.
 * 第2点的一个例子：OC与C++混编，如果在C++创建的子线程中创建了OC对象，需要自己添加@autoReleasePool，
 * 如果是在主线程创建的就不需要
 */

//----------------------------------------------------------------------------//
#pragma mark - 考点 监控主线程卡顿
//----------------------------------------------------------------------------//
/**
 * Runloop真正执行事件是在kCFRunLoopBeforeSources和kCFRunLoopAfterWaiting之后，
 * 通过计算kCFRunLoopBeforeSources到kCFRunLoopBeforeWaiting的时间，或者
 * kCFRunLoopAfterWaiting到kCFRunLoopBeforeTimers之前的运行时间，定一个标准，
 * 如执行超过30ms认为是卡顿。依此原理来检测主线程卡顿
 * 缺陷：无法捕获卡顿的线程堆栈
 */

//----------------------------------------------------------------------------//
#pragma mark - 考点 如何启动一个线程的Runloop
//----------------------------------------------------------------------------//
/**
 * 1. 为当前线程创建一个Runloop（调用GetCurrentRunloop会自动创建）
 * 2. 向Runloop中添加Source或Timer等维持Runloop的事件循环
 * 3. 调用run方法启动该Runloop
 */


//----------------------------------------------------------------------------//
#pragma mark - 考点 PerformSelector
//----------------------------------------------------------------------------//
/**
 * 1. 当调用NSObject的performSelecter:afterDelay:方法后，实际上其内部会创建
 *    一个Timer并添加到当前线程的Runloop中。如果当前线程的Runloop没有启动，则这
 *    个方法会失效。
 * 2. 同理，当调用 performSelector:onThread:时，实际上其会创建一个Timer加到对
 *    应的线程去，同样的，如果对应线程没有 RunLoop 该方法也会失效。
 */
