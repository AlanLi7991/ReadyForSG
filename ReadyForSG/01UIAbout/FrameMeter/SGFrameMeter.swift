//
//  SGFrameMeter.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/12.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------------------
// MARK: DisplayLink使用方法
//
// 官方文档:
// https://developer.apple.com/documentation/quartzcore/cadisplaylink
//-----------------------------------------------------------------------------
class SGFrameMeter: NSObject {

    var displayLink: CADisplayLink?
    var lastStamp: CFTimeInterval = 0
    var tickCount = 0
    
    override init() {
        super.init()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    //-----------------------------------------------------------------------------
    // MARK: 是个Timer所以需要手动关闭
    // A timer object that allows your application to
    // synchronize its drawing to the refresh rate of the display
    //-----------------------------------------------------------------------------
    public func stopLink() {
        displayLink?.invalidate()
    }
    
    @objc func tick() {
        guard let link = displayLink else { return }
        
        //-----------------------------------------------------------------------------
        // MARK: 官方推荐的计算帧率
        //-----------------------------------------------------------------------------
        let apple = Int(1/(link.targetTimestamp - link.timestamp))
        print("Apple FPS Calculate \(apple)")
        
        
        //-----------------------------------------------------------------------------
        // MARK: YYKit计算帧率
        //-----------------------------------------------------------------------------
        if tickCount == 0 {
            lastStamp = displayLink?.timestamp ?? 0
            return
        }
        tickCount += 1
        let delta = link.timestamp - lastStamp
        if delta < 1 {
            return
        }
        let yyKit = Int(Double(tickCount)/delta)
        print("YYKit FPS Calculate \(yyKit)")
        lastStamp = link.timestamp
        tickCount = 0
    }
    
}
