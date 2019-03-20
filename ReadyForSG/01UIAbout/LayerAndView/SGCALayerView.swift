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
            let img = self.drawBitmap()
            sleep(3)
            DispatchQueue.main.async {
                layer.contents = img
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
    
    //-----------------------------------------------------------------------------
    // MARK: 绘制位图
    // 官方文档:
    // https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html#//apple_ref/doc/uid/TP30001066-CH203-CJBHBFFE
    // 参考文档:
    // http://blog.leichunfeng.com/blog/2017/02/20/talking-about-the-decompression-of-the-image-in-ios/
    //-----------------------------------------------------------------------------
    
    func drawBitmap() -> CGImage {
        //Color Space 决定了用什么颜色排布
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        //Context 准备上下文（画布）
        // 参数注意点：
        // 1. data: 传入自己开辟的内存区，为null则自动分配
        // 2. bitsPerComponent 使用多少个bit代表一个颜色，是根据颜色空间的约定来的 常用 Bits per component（BPC）表示 255 就是 2^8 所以是8
        // 3. bytesPerRow: 每一行像素是多少个byte, 由于RGB+A是8*4 = 32bit， 共计4Byte，宽度100 所以是 100*4
        // 3-1. bytesPerRow: 使用0系统会进行Cache Line优化，通过设置成为CPU拷贝行数的倍数提高效率，会导致比手工算出来的大
        // 4. CGImageAlphaInfo: 一些颜色空间的标记位，常见的是像素排列是 RGBA 还是 ARGB 可以用这个声明
        let context = CGContext(data: nil, width: 100, height: 100, bitsPerComponent: 8, bytesPerRow: 100*4, space: colorSpace , bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        //设置 Fill的着色
        context?.setFillColor(UIColor.red.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 50, height: 50))
        //返回CGImage 合成后的图片结果
        let img = context?.makeImage()
        //图片合成完毕
        return img!
    }
}
