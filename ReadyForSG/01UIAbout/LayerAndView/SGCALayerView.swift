//
//  SGSampleView.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------------------
//MARK: 所有协议
// 1. UIResponder 响应链的协议，主要是处理touches 常用 touchesBegan等方法
//
// 2. NSCoding 键值编码，用于Archive对象
//
// 3. UIAppearance、UIAppearanceContainer 这个是NavigationBar之类的全局更改样式用的代理，这个Container是空的协议不知道为什么
//
// 5. UIDynamicItem 这个是物理动画用的，iOS7 引入
//
// 6. UITraitEnvironment、UICoordinateSpace SizeClass用的，布局的新的参考系，iOS8之后旋转会换坐标系
//
// 8. UIFocusItem、UIFocusItemContainer AppleTV开发用的 iOS10
//
// 3. CALayerDelegate 最重要的绘图用的代理
//-----------------------------------------------------------------------------

class SGCALayerView: UIView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.red.withAlphaComponent(0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //-----------------------------------------------------------------------------
    //MARK: UIView draw周期
    //-----------------------------------------------------------------------------

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("UIView: draw(rect:)")
    }

    override func draw(_ rect: CGRect, for formatter: UIViewPrintFormatter) {
        super.draw(rect, for: formatter)
        print("UIView: draw(rect:for:)")
    }

    //-----------------------------------------------------------------------------
    //MARK: CALayerDelegate draw周期
    //-----------------------------------------------------------------------------

//    override func display(_ layer: CALayer) {
//        super.display(layer)
//        print("CALayerDelegate: display(layer:)")
//    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        print("CALayerDelegate: draw(layer:in:)")
    }

    override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)
        print("CALayerDelegate: display(layerWillDraw:)")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        print("CALayerDelegate: display(layoutSublayers:)")
    }

    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        print("CALayerDelegate: action(for:\(layer) forKey:\(event))")
        return super.action(for: layer, forKey: event)
    }
}
