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
 * 一篇讲得比较全面的文章：
 * http://weslyxl.coding.me/2018/03/18/2018/3/RunLoop从源码到应用全面解析/
 *
 * Mark:
 * Runloop有C、OC和swift三套API，C语言的API是线程安全的，OC的API是非线程安全的。
 * 使用OC接口在某个线程中使用另一个线程的NSRunloop对象，可能出现奇怪的现象。
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
 * 1. kCFRunLoopDefaultMode：创建一个Runloop时的默认Mode，除了屏幕滑动和按键点击
 *    外，一般情况下处于该Mode
 * 2. UITrackingRunLoopMode：屏幕滑动时处于该Mode，如滑动tableview
 * 3. kCFRunLoopCommonMode：该Mode实际上只是一种标记，当Mode切换时，该Mode的Source、
 *    Observer和Timer会自动同步到当前运行的Mode中。这也是NSTimer在添加到runloop中的时
 *    候，要用NSRunLoopCommonModes作为参数的原因
 * 4. GSEventReceiveRunLoopMode：用于接收触摸、点击等事件以唤醒runloop的
 */
