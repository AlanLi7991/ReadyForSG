//
//  SGGCDViewController.swift
//  ReadyForSG
//
//  Created by vince on 2019/3/26.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

////////////////////////////// GCD //////////////////////////////
//
//  GCD源码：https://opensource.apple.com/tarballs/libdispatch/
//  深入理解GCD：https://bestswifter.com/deep-gcd/
//  GCD Swift的新语法：https://www.jianshu.com/p/b33015aee40d
//
//MARK: GCD
//  GCD 是拼凑多个队列，队列与线程的概念是分开的。
//  QOS: https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html
//  MainThread: User-interactive
//  DISPATCH_QUEUE_PRIORITY_HIGH: User-initiated
//  DISPATCH_QUEUE_PRIORITY_DEFAULT: Default
//  DISPATCH_QUEUE_PRIORITY_LOW: Utility
//  DISPATCH_QUEUE_PRIORITY_BACKGROUND: Background
//
//MARK: 同步、异步 -- 串行、并行
//  同步的任何操作都不会创建线程
//  异步操作：1.主队列不会创建线程
//          2.串行，创建一个线程，串行执行
//          3.并发队列，根据线程池不断创建线程，去并行执行任务
//
//MARK: dispatch_barrier_async/dispatch_barrier_sync
//  可将多个并行的执行分割开来
//  可进行多读，单写
//  block参数会被目标队列复制并持有。目标队列必须是用户手动创建的并发队列，如果传入的是串行队列或者是全局并发队列，那么这个函数就和dispatch_async类似。
//  dispatch_barrier_sync函数的目标线程不会复制和持有block
//
//MARK: group 使用
//  group enter, group leave
//  __dispatch_group_async
//
//MARK: DispatchWorkItem代替dispatch_block_t
//  flags: https://developer.apple.com/documentation/dispatch/dispatch_block_flags_t
//  apple flags: https://github.com/apple/swift-corelibs-libdispatch/blob/master/dispatch/block.h
//  assignCurrentContext: Set the attributes of the work item to match the attributes of the current execution context.
//                        说明该块会被分配在创建该对象的上下文中（直接执行该块对象时推荐使用）
//  detached: Disassociate the work item's attributes from the current execution context.
//            表明dispatch_block与当前的执行环境属性无关
//  enforceQoS: Prefer the quality-of-service class associated with the block.
//              当dispatch_block提交到队列或者直接提交执行做同步操作时，该值是默认值
//  inheritQoS: Prefer the quality-of-service class associated with the current execution context.
//              异步执行的默认值，优先级低于DISPATCH_BLOCK_ENFORCE_QOS_CLASS。可以用该值来覆盖原来QOS类
//  noQoS: Execute the work item without assigning a quality-of-service class.
//         表明dispatch_block不分配QOS类
//  barrier: Cause the work item to act as a barrier block when submitted to a concurrent queue.
//
//MARK: @convention(XXXX）修饰符
//  @convention(swift) : 表明这个是一个swift的闭包
//  @convention(block) ：表明这个是一个兼容oc的block的闭包
//  @convention(c) : 表明这个是兼容c的函数指针的闭包。
//
//MARK: 闭包关键字
//  @escaping: 逃逸闭包，返回值后再执行，or 异步执行
//  @autoclosure: 自动闭包。简化参数传递，延迟执行时间。即可以让返回该参数类型的闭包作为参数
//                其只可以修饰作为参数的闭包类型
//                并不支持带有输入参数的写法，也就是说只有形如 () -> T 的参数才能使用这个特性进行简化。
//  @autoclosure 与 @escaping 是可以兼容的，放置顺序可以颠倒。
//
//MARK: DispatchSource
//  https://heisenbean.me/2017/06/A-deep-dive-into-Grand-Central-Dispatch-in-Swift/
//
//MARK: 新增函数
//  https://wangwangok.github.io/2017/07/29/gcd_basic/
//  https://wangwangok.github.io/2017/07/29/gcd_func/
//  dispatch_block_testcancel：让我们能够知道当前任务块是否已经被取消。
//  dispatch_block_cancel：可以取消未执行的block，我们必须要确定即将被cancle的块没有捕获任何其他外部变量，如果持有将会造成内存泄漏。
//  dispatch_block_wait: 以同步的方式执行并等待，得等待指定的任务块执行完成之后，抑或者是超时之后然后去执行当前线程的后续任务
//  dispatch_xxxx_f: 入参将使用函数指针，不采用dispatch_block_t的方式
//  dispatch_block_perform: 以同步的方式执行block，性能更好，不需要copy到堆，或者创建到堆
//  dispatch_apply: dispatch_sync函数配合不同的的dispatch_queue_t队列，来循环执行任务。
//
///////////////////////////////////////////////////////////////////////

class SGGCDViewController: UIViewController {

    let action = SGActionRune()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        action.attach(viewController: self)
        
        action.alert.addAction(UIAlertAction.init(title: "convension 修饰符", style: .default, handler: { [weak self] (_) in
            self?.runConvention();
        }))
        
        action.alert.addAction(UIAlertAction.init(title: "子线程同步调用", style: .default, handler: { [weak self] (_) in
            self?.runSyncSerialQueue()
        }))
        
        action.alert.addAction(UIAlertAction.init(title: "子线程异步调用", style: .default, handler: { [weak self] (_) in
            self?.runAsyncSerialQueue()
        }))
        
        action.alert.addAction(UIAlertAction.init(title: "调用Group", style: .default, handler: { [weak self] (_) in
            self?.runGroup()
        }))
        
        action.alert.addAction(UIAlertAction.init(title: "子线程调用WorkItem", style: .default, handler: { [weak self] (_) in
            self?.runCustomQueue()
        }))
        
        action.alert.addAction(UIAlertAction.init(title: "auto closure", style: .default, handler: { [weak self] (_) in
            self?.autoClosure(closure: "n" == "b")
            
            self?.escapingAndAutoClosure(block: "1" == "1")
        }))
        
        action.alert.addAction(UIAlertAction.init(title: "barrier 使用实例", style: .default, handler: { [weak self] (_) in
            self?.runBarrier()
        }))
        
        action.alert.addAction(UIAlertAction.init(title: "新增函数调用", style: .default, handler: { [weak self] (_) in
            self?.runApply()
        }))
        
        let workitem1 = DispatchWorkItem.init(qos: .userInteractive, flags: .inheritQoS) {
            [weak self] () -> Void in
            print("userInteractive")
            self?.getCurrentThread()
        }
        let workitem2 = DispatchWorkItem.init(qos: .userInitiated, flags: .inheritQoS) {
            [weak self] () -> Void in
            print("userInitiated")
            self?.getCurrentThread()
        }
        let workitem3 = DispatchWorkItem.init(qos: .default, flags: .inheritQoS) {
            [weak self] () -> Void in
            print("default")
            self?.getCurrentThread()
        }
        let queue = DispatchQueue.init(label: "serial")
        queue.async(execute: workitem1)
        queue.async(execute: workitem2)
        queue.async(execute: workitem3)
//        workitem3.perform()
//        workitem2.perform()
//        workitem1.perform()
    }
    
    //MARK: 新增函数
    func runApply() -> Void {
        DispatchQueue.concurrentPerform(iterations: 5) { (i) in
            print("index \(i)")
        }
        print("iteraction end")
//        dispatch_apply(5, DispatchQueue.global(), {
//            (size_t size) in
//
//        })
    }
    
    //MARK: barrier 操作
    func runBarrier() -> Void {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            print("read")
        }
        queue.async {
            print("read")
        }
        queue.async(execute: DispatchWorkItem.init(qos: .userInteractive, flags: .barrier, block: {
            [weak self] () -> Void in
            print("write")
            self?.getCurrentThread()
        }))
    }
    
    //MARK: 闭包关键字
    func autoClosure(closure: @autoclosure () -> Bool) -> Void {
        if closure() {
            print("block auto closure")
        } else {
            print("block not auto closure")
        }
    }
    
    func escapingAndAutoClosure(block: @escaping @autoclosure () -> Bool) -> Void {
        DispatchQueue.global().async {
            if block() {
                print("escaping autoclosure working")
            } else {
                print("escaping autoclosure failure")
            }
        }
    }
    
    //MARK: @convention(XXXX）修饰符
    func runConvention() -> Void {
        let swiftCallback : @convention(c) (Float, Float) -> Float = {
            (x, y) -> Float in
            return x + y;
        }
        
        print("C convention function: \(AddCFunction(swiftCallback))")
    }
    
    func runCustomQueue() -> Void {
        print("\n\n")
        
        let workItem = DispatchWorkItem.init(qos: .userInteractive, flags: .enforceQoS) {
            self.getCurrentThread()
        }
        DispatchQueue.global(qos: .default).async(execute: workItem)
        DispatchQueue.global(qos: .userInteractive).async(execute: workItem)
    }
    
    //MARK: group 使用
    func runGroup() -> Void {
        let group = DispatchGroup.init()
        let concurrent = DispatchQueue.global(qos: .default)
        
        let musicWorkItem = DispatchWorkItem.init(qos: .background, flags: .detached) {
            
        }
        concurrent.async(group: group, execute: musicWorkItem)
        
        group.enter()
        concurrent.async {
            print("group enter leave")
            group.leave()
        }
        
        group.notify(queue: concurrent) {
            print("group finish")
        }
        
        musicWorkItem.wait()
        
        group.wait()
        print("group wait")
    }
    
    //MARK: 同步、异步 -- 串行、并行
    func runAsyncSerialQueue() -> Void {
        let queue = DispatchQueue(label: "SERIAL")
        for _ in 0...5 {
            queue.async { [weak self] in
                self?.getCurrentThread()
            }
        }
    }
    
    func runSyncSerialQueue() -> Void {
        let queue = DispatchQueue(label: "SERIAL")
        queue.sync { [weak self] in
            self?.getCurrentThread()
        }
    }
    
    func getCurrentThread() -> Void {
        let currentThread = Thread.current
        let enumValue = currentThread.qualityOfService.rawValue
        print("current thread :\(currentThread) Priority: \(currentThread.threadPriority) QOS: \(enumValue)")
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "GCD"
        return rune
    }
}
