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
//  GCD源码：https://github.com/apple/swift-corelibs-libdispatch
//  深入理解GCD：https://bestswifter.com/deep-gcd/
//
//MARK: 同步、异步 -- 串行、并行
//  同步的任何操作都不会创建线程
//  异步操作：1.主队列不会创建线程
//          2.串行，创建一个线程，串行执行
//          3.并发队列，根据线程池不断创建线程，去并行执行任务
//
//MARK: dispatch_barrier_async
//  可将多个并行的执行分割开来
//  可进行多读，单写
//
//MARK: group
//  group enter, group leave
//  __dispatch_group_async
//
//MARK: DispatchWorkItem
//  新增内容
//
///////////////////////////////////////////////////////////////////////

class SGGCDViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        runSyncSerialQueue()
//        runAsyncSerialQueue()
        runGroup()
    }
    
    func runGroup() -> Void {
        let group = DispatchGroup.init()
        let concurrent = DispatchQueue.global(qos: .default)
        
        __dispatch_group_async(group, concurrent, {
            print("group __dispatch_group_async")
            group.enter()
            print("group __dispatch_group_async enter")
            concurrent.async(execute: {
                print("group __dispatch_group_async leave")
                group.leave()
            })
        })
        
        group.enter()
        concurrent.async {
            print("group enter leave")
            group.leave()
        }
        
        group.notify(queue: concurrent) {
            print("group finish")
        }
        
        group.wait()
        print("group wait")
    }
    
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
        print("current thread :\(currentThread)")
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "GCD"
        return rune
    }
}
