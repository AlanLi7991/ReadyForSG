//
//  SGNSThreadViewController.swift
//  ReadyForSG
//
//  Created by vince on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

////////////////////////////// 介绍 //////////////////////////////
//  -----------------------------------------------------------  //
//  MARK: 介绍
//  -----------------------------------------------------------  //
//
//  stackSize: 一定要在线程使用前（start）设置，才会起效。默认是512KB。如果修改了此值，会导致currentThread获取到失效的指针
//
//  显示创建线程
//  隐示创建线程
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// Quality Of Service //////////////////////////////
//  -----------------------------------------------------------  //
//  MARK: Quality Of Service
//  -----------------------------------------------------------  //
//
//    typedef NS_ENUM(NSInteger, NSQualityOfService) {
//        //刷新UI级别的线程
//        NSQualityOfServiceUserInteractive = 0x21,
//        //用户请求的无需精确的任务的线程，例如点击加载邮件
//        NSQualityOfServiceUserInitiated = 0x19,
//        //周期性的任务线程，例如定时刷新
//        NSQualityOfServiceUtility = 0x11,
//        //后台任务的线程
//        NSQualityOfServiceBackground = 0x09,
//        //优先级未知的线程，优先级介于UserInteractive和Utility之间
//        NSQualityOfServiceDefault = -1
//    } API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// NSNotification //////////////////////////////
//  -----------------------------------------------------------  //
//  MARK: NSNotification
//  -----------------------------------------------------------  //
//
//  当调用 detachNewThreadSelector，start 进行线程切换是调用。只会调用一次。此被回调会在主线程，而且会在新线程执行前调用
//  NSWillBecomeMultiThreaded
//
//  没有实现
//  NSDidBecomeSingleThreaded
//
//  在线程即将退出时，调用此通知，会在子线程中调用
//  NSThreadWillExit
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// 自定义子线程 //////////////////////////////
//
//  可以继承NSThread，实现自己的线程操作。
//  如果想做到线程被外界调用cancel时，立马退出，可以监测 isCancelled
//
///////////////////////////////////////////////////////////////////////

//Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Can't set stack size to a value lower than 8192 (requested 4096)'

class SGNSThreadViewController: UIViewController {
    
    var threads : [Thread] = [Thread]()
    var residentThread : Thread?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationList = [NSNotification.Name.NSWillBecomeMultiThreaded,
                                NSNotification.Name.NSDidBecomeSingleThreaded,
                                NSNotification.Name.NSThreadWillExit]
        for item in notificationList {
            NotificationCenter.default.addObserver(self, selector: #selector(notifyCall(notify:)), name: item, object: nil)
        }
        
        // 常驻线程实现
        self.residentThread = Thread.init(target: self, selector: #selector(run), object: nil);
        self.residentThread?.name = "resident thread"
        self.residentThread?.start()
        self.perform(#selector(threadOperation), on: self.residentThread!, with: nil, waitUntilDone: false)
        
        print("main thread is Multi Threaded: \(Thread.isMultiThreaded())")
        
        print("detachNewThreadSelector")
        Thread.detachNewThreadSelector(#selector(threadOperation), toTarget: self, with: nil)
        
        print("detachNewThread")
        Thread.detachNewThread({
            print("detachNewThread")
        })
        sleep(1)
        
        print("\nNSThread 创建")
        
        for n in 0...2 {
            let initThread = Thread.init(target: self, selector: #selector(threadOperation), object: nil)
//            initThread.stackSize = 8192
            initThread.qualityOfService = QualityOfService.userInteractive
            initThread.threadPriority = 0.9
            initThread.name = "low priority: \(n)"
        
            let highPriorityThread = Thread.init(target: self, selector: #selector(threadOperation), object: nil)
//            highPriorityThread.stackSize = 12288
            highPriorityThread.qualityOfService = QualityOfService.userInteractive
            highPriorityThread.threadPriority = 1
            highPriorityThread.name = "high priority: \(n)"
            
            self.threads.append(initThread)
            self.threads.append(highPriorityThread)
            
            initThread.start()
            highPriorityThread.start()
        }
        
        sleep(1)
        
        self.performSelector(inBackground: #selector(threadOperation), with: nil)
    }
    
    @objc func threadOperation() -> Void {
        let currentThread = Thread.current
        var printContent = String()
        printContent += "\nthread: \(currentThread)\nstack size: \(currentThread.stackSize)\n"
        printContent += "is Multi Threaded: \(Thread.isMultiThreaded())\n"
        printContent += "priority 优先级：\(currentThread.threadPriority)\n"
        printContent += "quality of service: \(Float(currentThread.qualityOfService.rawValue))\n"
        printContent += "call stack address: \(Thread.callStackReturnAddresses)\n"
        printContent += "call stack symbols: \n\((Thread.callStackSymbols).joined(separator: "\n"))\n"
        print(printContent)
        
        // 以下的方式，会导致打印混在一起
//        print("thread: \(currentThread)\nstack size: \(currentThread.stackSize)")
//        print("is Multi Threaded: \(Thread.isMultiThreaded())")
//        print("priority 优先级：\(currentThread.threadPriority)")
//        print("quality of service: \(Float(currentThread.qualityOfService.rawValue))")
//        print("call stack address: \(Thread.callStackReturnAddresses)")
//        print("call stack symbols: \n\((Thread.callStackSymbols).joined(separator: "\n"))")
        
//            Thread.exit()
    }
    
    @objc func notifyCall(notify : NSNotification) -> Void {
        let thread = notify.object as? Thread
        print("😂 notify: \(notify) isfinish: \(thread?.isFinished ?? false)")
    }
    
    @objc func run() -> Void {
        RunLoop.current.add(Port.init(), forMode: RunLoop.Mode.default)
        RunLoop.current.run()
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "NSThread"
        return rune
    }
}
