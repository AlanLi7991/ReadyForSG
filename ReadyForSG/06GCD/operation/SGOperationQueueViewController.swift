//
//  SGOperationQueueViewController.swift
//  ReadyForSG
//
//  Created by vince on 2019/3/31.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit
//  -----------------------------------------------------------  //
//  MARK: NSOperation (非线程安全）
//  -----------------------------------------------------------  //
//
//  简单介绍：https://nshipster.cn/nsoperation/
//  简单深入Operation: http://zxfcumtcs.github.io/2016/05/17/NSOperation/
//  Operation，OperationQueues总结：https://juejin.im/post/5a9e57af6fb9a028df222555
//  isReady -> isExcusing -> isFinished
//  isReady: 是判断是否可以执行了，如果有依赖，会等待依赖项变成isFinished时，才会变成YES
//  isFinished: 已经执行完成 or 被取消出列
//  QueuePriority: 执行的顺序。同一 queue 中 operation 间执行的优化级
//  qualityOfService: 在系统层面，operation 与其他线程获取资源的优先级。CPU，网络，Disk资源抢夺
//  threadPriority: 使用的线程优先级，8.0后不再支持
//  addDependency: 依赖性，通过isFinished属性来保证执行的顺序。
//  NSInvocationOperation: 可通过selector or NSInvocation来执行，swift没有，只有继承NSOperation的子类
//
//
//  -----------------------------------------------------------  //
//  MARK: NSBlockOperation
//  -----------------------------------------------------------  //
//  addExecutionBlock: 就可以为 NSBlockOperation 添加额外的操作。这些操作（包括 blockOperationWithBlock 中的操作）可以在不同的线程中同时（并发）执行。
//                     只有当所有相关的操作已经完成执行时，才视为完成。
//                     如果添加了此操作，会导致别的block会在不同的线程执行
//
//
//  -----------------------------------------------------------  //
//  MARK: NSOperationQueue(非线程安全）
//  -----------------------------------------------------------  //
//  qualityOfService: 如果operation有设置此值，将不使用queue中的此值
//  main：不用自己管理状态，如果被调用了cancel，这个方法不会被执行
//  start: 要自己管理状态
//
//  -----------------------------------------------------------  //
//  MARK: AFNetworking
//  -----------------------------------------------------------  //
//  AFNetworking 2.3.1 最后一代用NSOperation。
//  AFNetworking 3.0 全面使用 NSURLSession，而 NSURLSession 本身是异步的、且没有 NSURLConnection 需要 runloop 配合的问题
//

class SGOperationQueueViewController: UIViewController {
    
    let action = SGActionRune()

    override func viewDidLoad() {
        super.viewDidLoad()

        action.alert.addAction(UIAlertAction.init(title: "Quality Of Service资源抢夺", style: .default, handler: { [weak self] (_) in
            self?.runQualityOfService()
        }))
        
        self.runAddExectionBlock()
    }
    
    func runAddExectionBlock() -> Void {
        let block1 = BlockOperation.init {
            [weak self] () in
            self?.getCurrentThread("init block")
        }
        
        block1.addExecutionBlock {
            [weak self] () in
            self?.getCurrentThread("execution block")
        }
        
        block1.addExecutionBlock {
            [weak self] () in
            self?.getCurrentThread("execution block")
        }
        
        block1.addExecutionBlock {
            [weak self] () in
            self?.getCurrentThread("execution block")
        }
        
        block1.start()
    }
    
    func runQualityOfService() -> Void {
        let queue = OperationQueue.init()
        let block1 = BlockOperation.init {
            print("block one userInteractive")
        }
        block1.qualityOfService = .userInteractive
        let block2 = BlockOperation.init {
            print("block two background")
        }
        queue.maxConcurrentOperationCount = 10
        queue.addOperation(block2)
        queue.addOperation(block1)
    }
    
    func getCurrentThread(_ customStr: String) -> Void {
        let currentThread = Thread.current
        let enumValue = currentThread.qualityOfService.rawValue
        print("current thread :\(currentThread) Priority: \(currentThread.threadPriority) QOS: \(enumValue) custom: \(customStr)")
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Operation Queue"
        return rune
    }
}
