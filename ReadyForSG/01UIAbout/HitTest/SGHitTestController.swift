//
//  SGHitTestController.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//


import UIKit

class SGHitTestController: UIViewController {

    //-----------------------------------------------------------------------------
    //MARK: 先后顺序
    // 1. HitTest先调用
    // 2. PointInside后调用
    // 3. 很容易掉用两次，官方回复是正常的 参考2
    // 参考：
    // http://hongchaozhang.github.io/blog/2015/10/21/touch-event-in-ios/
    // https://lists.apple.com/archives/cocoa-dev/2014/Feb/msg00118.html
    //-----------------------------------------------------------------------------
    
    
    //-----------------------------------------------------------------------------
    //MARK: 如何做一个可穿透的容器
    // 1. 重写HitTest
    // 2. 检查Super返回的UIView 存在两种可能 self 或者 self的某一个子View
    // 3. 如果是self， 则返回nil 代表HitTest未击中任何View
    //-----------------------------------------------------------------------------
    
    
    //-----------------------------------------------------------------------------
    //MARK: 如何扩大Button的点击范围
    // 1. 重写HitTest
    // 2. 扩大自己的Bounds 使用负数 InsetIn()
    // 3. 如果包含了当前点则返回自己
    //-----------------------------------------------------------------------------
    
    
    //-----------------------------------------------------------------------------
    //MARK: Event 是什么
    // 1. touches 的容器 根据type 可以确定是来自摇一摇 按音量键 还是触摸屏幕
    // 2. 通过 subType判断具体的事件
    // 3. 只有继承自UIResponder类的对象才能处理事件
    // 4. 因为可以多点触摸，所以UITouch使用了一个Set来存
    // 5. 考点： 响应者链条
    // 参考：
    // http://zhoon.github.io/ios/2015/04/12/ios-event.html
    // http://hongchaozhang.github.io/blog/2015/10/21/touch-event-in-ios/
    //-----------------------------------------------------------------------------
    
    
    let label = UILabel()
    let hitView = SGHitTestView()
    let expandBtn = SGHitExpandButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(label)
        view.addSubview(hitView)
        view.addSubview(expandBtn)

        
        let guide = self.view.safeAreaLayoutGuide
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap any where"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.black
        
        hitView.translatesAutoresizingMaskIntoConstraints = false
        expandBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: guide.topAnchor),
            label.rightAnchor.constraint(equalTo: guide.rightAnchor),
            label.leftAnchor.constraint(equalTo: guide.leftAnchor),
            label.heightAnchor.constraint(equalToConstant: 50),
            hitView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            hitView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            hitView.widthAnchor.constraint(equalToConstant: 200),
            hitView.heightAnchor.constraint(equalToConstant: 100),
            expandBtn.topAnchor.constraint(equalTo: hitView.bottomAnchor, constant: 20),
            expandBtn.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            expandBtn.widthAnchor.constraint(equalToConstant: 100),
            expandBtn.heightAnchor.constraint(equalToConstant: 20),
            
            ])
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Hit Test Sample"
        return rune
    }

}
