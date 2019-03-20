//
//  SGCALayer.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/14.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------------------
// MARK: CALayer的常见类
//
// 1. CAShapeLayer: 一个方便的图形Layer
// 2. CATextLayer: 一个文字的Layer
// 3. CAGradientLayer: 一个渐变色的Layer
//
// 以上三个类都是 CALayer的子类，不用手动去调用CoreCraphics的C方法可以达到绘图效果
//
// 4. CAConstraint: 一个类似AutoLayout的布局约束
// 5. CAAction: 所有的Layer变化都会被封装成CAAction，包括透明度大小内容等通过KVC来做用于CALayer
//
//-----------------------------------------------------------------------------
class SGCALayer: CALayer {

    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        print("CALayer: setNeedsDisplay)")
    }
    
    override func setNeedsDisplay(_ r: CGRect) {
        super.setNeedsDisplay(r)
        print("CALayer: setNeedsDisplay(_ rect:)")
    }
    
    //-----------------------------------------------------------------------------
    // MARK: CAAction何时会显示图像
    //
    // 触发 CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:contents)
    // 会更改 contents 见到可视图像，可以参考 SGCALayerView 的日志
    //-----------------------------------------------------------------------------
    override func display() {
        super.contents = super.contents
    }
    
}
