//
//  SGLockViewController.swift
//  ReadyForSG
//
//  Created by vince on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

////////////////////////////// 锁类型 //////////////////////////////
//MARK: 锁类型
//
//  https://bestswifter.com/ios-lock/
//
//MARK: 锁类型 -- OSSpinLock
//  OSSpinLock: 自旋锁，本身的实现是通过do-while的方式等待，性能是最好的。存在优先级反转引起问题
//              低优先级的线程获得锁，高优先级的线程，会处于 spin lock 的忙等状态。两个线程会争夺大量的CPU时间。
//  不再安全的OSSpinLock: https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/
//  1.truly unbounded backoff 算法: 负荷大时还是会导致数十秒
//  2.handoff lock 算法: 锁的持有者会把线程 ID 保存到锁内部，锁的等待者会临时贡献出它的优先级来避免优先级反转的问题。
//    (libobjc所使用)     理论上这种模式会在比较复杂的多锁条件下产生问题，但实践上目前还一切都好。
//
//MARK: 锁类型 -- dispatch_semaphore_t
//  dispatch_semaphore_t: 信号量，本质是通过调用lll_futex_wait(系统的SYS_futex),使线程进入睡眠状态，主动让出时间片
//                        主动让出时间片,引起 10微秒 上下文切换，至少需要两次切换
//                        如果等待时间很短，比如只有几个微秒，忙等就比线程睡眠更高效。
//
//MARK: 锁类型 -- pthread_mutex
//  pthread_mutex: 互斥锁。阻塞线程并睡眠，需要进行上下文切换，与信号量很像
//  有以下的类型：
//  PTHREAD_MUTEX_NORMAL 缺省类型，也就是普通锁。当一个线程加锁以后，其余请求锁的线程将形成一个等待队列，并在解锁后先进先出原则获得锁。
//  PTHREAD_MUTEX_ERRORCHECK 检错锁，如果同一个线程请求同一个锁，则返回 EDEADLK，否则与普通锁类型动作相同。这样就保证当不允许多次加锁时不会出现嵌套情况下的死锁。
//  PTHREAD_MUTEX_RECURSIVE 递归锁，允许同一个线程对同一个锁成功获得多次，并通过多次 unlock 解锁。
//  PTHREAD_MUTEX_DEFAULT 适应锁，动作最简单的锁类型，仅等待解锁后重新竞争，没有等待队列。
//  注意：由于 pthread_mutex 有多种类型，可以支持递归锁等，因此在申请加锁时，需要对锁的类型加以判断
//
//MARK: 锁类型 -- NSLock
//  NSLock: OC表面，内部封装了一个 pthread_mutex，属性为 PTHREAD_MUTEX_ERRORCHECK，它会损失一定性能换来错误提示
//          它需要经过方法调用，同时由于缓存的存在，多次方法调用不会对性能产生太大的影响。
//
//MARK: 锁类型 -- NSCondition
//  NSCondition: 条件锁，通过条件变量(condition variable) pthread_cond_t 来实现的
//               封装了一个互斥锁和条件变量
//  无法使用 互斥锁 来模拟，无法保证顺序
//  可以使用 dispatch_semaphore_t 来模拟，但是无法实现 broadcast
//
//MARK: 锁类型 -- NSRecursiveLock
//  NSRecursiveLock: 递归锁，NSLock 的区别在于内部封装的 pthread_mutex_t 对象的类型不同，前者的类型为 PTHREAD_MUTEX_RECURSIVE
//
//MARK: 锁类型 -- NSConditionLock
//  NSConditionLock: 借助 NSCondition，_condition_value 两个合并起来
//
//MARK: 锁类型 -- @synchronized
//  @synchronized：OC 层面的锁， 主要是通过牺牲性能换来语法上的简洁与可读
//                通过一个哈希表来实现的，OC 在底层使用了一个互斥锁的数组(你可以理解为锁池)，通过对对象去哈希值来得到对应的互斥锁。
//  实现原理：http://yulingtianxia.com/blog/2015/11/01/More-than-you-want-to-know-about-synchronized/
//
///////////////////////////////////////////////////////////////////////



class SGLockViewController: UIViewController {
    
    var lock : pthread_mutex_t?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        createPthreadMutex()
        threadMethord(5)
    }
    
    // MARK: NSCondition
    func createConditionLock() -> Void {
        print("OC 条件锁")
        let lock = NSCondition.init()
        lock.signal()
        lock.wait()
    }
    
    // MARK: pthread_mutex: 互斥锁 实现方法
    func createPthreadMutex() -> Void {
        print("互斥锁 -- 递归锁")
        var attr : pthread_mutexattr_t = pthread_mutexattr_t()
        self.lock = pthread_mutex_t()
        
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&self.lock!, &attr)
        pthread_mutexattr_destroy(&attr)
    }
    
    func threadMethord(_ value : Int) -> Void {
        pthread_mutex_lock(&self.lock!)
        
        if (value > 0) {
            print("Value: \(value)")
            sleep(1)
            self.threadMethord(value - 1)
        }
        
        pthread_mutex_unlock(&self.lock!)
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Lock"
        return rune
    }
}
