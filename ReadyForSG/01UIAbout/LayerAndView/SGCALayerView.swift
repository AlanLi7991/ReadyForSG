//
//  SGSampleView.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit
import CoreGraphics

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

    let subLayer = SGCALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.subLayer.frame = CGRect(x: 100, y: 100, width: 50, height: 50)
        self.subLayer.backgroundColor = UIColor.yellow.withAlphaComponent(0.5).cgColor
        self.layer.addSublayer(subLayer)
        backgroundColor = UIColor.red.withAlphaComponent(0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //-----------------------------------------------------------------------------
    //MARK: UIView draw周期 https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/
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
    // 1. 是否实现 display(_ layer: CALayer) 代理会影响Layer的绘制声明周期
    // 2. 如果实现了display 但是仅仅调用了Super 会Crash
    //-----------------------------------------------------------------------------
    // 不实现Display Delegate
    //-----------------------------------------------------------------------------
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:_uikit_viewPointer)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:bounds)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:opaque)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:contentsScale)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:rasterizationScale)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:position)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:opaque)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:onOrderIn)
    //CALayerDelegate: layoutSublayers(_:)
    //<------------------
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:contentsFormat)
    //CALayerDelegate: layerWillDraw(_:)
    //UIView: draw(rect:)
    //CALayerDelegate: draw(layer:in:)
    //------------------>
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:contents)
    //-----------------------------------------------------------------------------
    // 实现了Display Delegate
    //-----------------------------------------------------------------------------
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:_uikit_viewPointer)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:bounds)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:opaque)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:contentsScale)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:rasterizationScale)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:position)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:opaque)
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:onOrderIn)
    //CALayerDelegate: layoutSublayers(_:)
    //<------------------
    //CALayerDelegate: display(layer:)
    //------------------>
    //CALayerDelegate: action(for:<CALayer: 0x600001698d20> forKey:contents)
    //-----------------------------------------------------------------------------
    // 区别在于
    // 1. 会不会出发UIView的 DrawRect
    // 2. 会不会调用 layerWillDraw(_:) draw(layer:in:)
    //-----------------------------------------------------------------------------

    override func display(_ layer: CALayer) {
        DispatchQueue.global().async {
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            let context = CGContext(data: nil, width: 100, height: 100, bitsPerComponent: 8, bytesPerRow: 400, space: colorSpace , bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            context?.setFillColor(UIColor.red.cgColor)
            context?.fill(CGRect(x: 0, y: 0, width: 50, height: 50))
            let img = context?.makeImage()
            sleep(3)
            DispatchQueue.main.async {
                layer.contents = img!
            }
        }
        print("CALayerDelegate: display(layer:)")
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        print("CALayerDelegate: draw(layer:in:)")
    }

    override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)
        print("CALayerDelegate: layerWillDraw(_:)")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        print("CALayerDelegate: layoutSublayers(_:)")
    }

    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        print("CALayerDelegate: action(for:\(layer) forKey:\(event))")
        return super.action(for: layer, forKey: event)
    }
}
