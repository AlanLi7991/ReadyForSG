//
//  SGCPUView.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/15.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------------------
//MARK: 总结CPU优化的注意点
//前提:
// 1. 单核时代不用考虑CPU优化，因为只有一个CPU只能支持主线程
// 2. 多核时代可以利用第二个CPU进行一些运算，但是底层代码还是单线程的，所以才有了优化的空间
//参考:
//https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/
//-----------------------------------------------------------------------------
class SGCPUView: UIView {

    //-----------------------------------------------------------------------------
    //MARK: 优化1: 对象创建(不重要)
    // 1. 能用轻量级对象就不要用重量级
    // 2. 比如用CALayer做SubLayer而不是UIView做SubView
    //-----------------------------------------------------------------------------
    lazy var render = CALayer()
    
    //-----------------------------------------------------------------------------
    //MARK: 优化2: 对象调整(不重要)
    //-----------------------------------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //对象调整能少就少
        render.backgroundColor = UIColor.magenta.withAlphaComponent(0.5).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //-----------------------------------------------------------------------------
    //MARK: 优化3: 对象销毁(！！重要！！)
    // 1. 对象可以使用Block丢到全局线程销毁
    // 2. 躲开了在主线程释放对象的时间 由子线程的AutoReleasePool回收
    //-----------------------------------------------------------------------------
    
    deinit {
        DispatchQueue.global().async { [weak self] in
            //此处render被capture
            //由global的 AutoReleasePool回收
            let _ = self?.render
        }
    }
    
    //-----------------------------------------------------------------------------
    //MARK: 优化4/5: 布局计算/AutoLayout(不重要)
    // 1. AutoLayout 会更消耗资源
    // 2. 大量出现的Cell 最好用Frame
    //-----------------------------------------------------------------------------
    func layoutCurrent(origin: CGPoint) {
        self.frame = CGRect(origin: origin, size: CGSize(width: 100, height: 100))
    }
    
    //-----------------------------------------------------------------------------
    //MARK: 优化6: 文本计算(！！重要！！)
    // 1. 需要在绘制接口使用如 drawRect 或者 dislay(_ layer:)
    //-----------------------------------------------------------------------------
    func patternText() {
        //构造文字
        let attributeString = NSMutableAttributedString(string: "Example String", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            ])
        attributeString.addAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.backgroundColor : UIColor.black,
            ], range: NSRange(location: 0, length: 7))
        
        attributeString.addAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.backgroundColor : UIColor.red,
            ], range: NSRange(location: 8, length: 6))
        //算出文字bound
        // 1. constrain 用来限制宽度 100（换行），高度（1000）
        // 2. 如果文字过多是有可能画不下
        let constrain = CGSize(width: 100, height: 1000)
        let bounding = attributeString.boundingRect(with: constrain, options: NSStringDrawingOptions.usesFontLeading, context: nil)
        //准备绘制属性
        let drawRect = CGRect(origin: CGPoint(x: 100, y: 50), size: bounding.size)
        let drawOpt = NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.usesDeviceMetrics.rawValue)
        let drawContext = NSStringDrawingContext()
        drawContext.minimumScaleFactor = 0.5
        //Draw到当前Context上
        //1. 可以在Display的Delegate里调用
        //2. 或者 UIGraphicsGetCurrentContext() 获取到当前的Context
        attributeString.draw(with: drawRect, options:drawOpt , context: drawContext)
    }
    
    //-----------------------------------------------------------------------------
    //MARK: 优化7 文本渲染(！！重要！！)
    // 1. 如果真的很复杂可以用CoreText自定义文本空间
    // 2. CoreText 是 CoreGraphics的文字接口，以CT开头
    // 3.  需要在绘制接口使用如 drawRect 或者 dislay(_ layer:)
    // 参考
    // https://blog.devtang.com/2015/06/27/using-coretext-1/
    //-----------------------------------------------------------------------------
    func customTextRender() {
        print(CTGetCoreTextVersion())
        //Draw哪里
        let context = UIGraphicsGetCurrentContext()
        //Path按照什么轨迹排列
        let path = CGMutablePath()
        path.addArc(center: self.center, radius: 20, startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: true)
        //获得绘制的CTFrame
        let string = NSAttributedString(string: "CoreText")
        let framesetter = CTFramesetterCreateWithAttributedString(string)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 8), path, nil)
        //开始绘制
        CTFrameDraw(frame, context!)
        
    }
    
    //-----------------------------------------------------------------------------
    //MARK: 优化8: 图片解码(！！重要！！)
    // 1. JPEG、PNG都是压缩格式，显示成Bitmap需要解压缩
    // 2. JPEG是有损压缩，PNG是无损压缩，所以系统函数参数不一致
    //    a. UIImagePNGRepresentation(UIImage * __nonnull image)
    //    b. UIImageJPEGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality)
    //    c. 这两个方法在Swift里变成了实例方法，通过UIImage的Instance可以调取
    //
    // 3. YYKit通过设置为0利用系统的CacheLine优化
    //
    // 参考文档:
    // http://blog.leichunfeng.com/blog/2017/02/20/talking-about-the-decompression-of-the-image-in-ios/
    // Cache Line知识点:
    // 1. https://stackoverflow.com/questions/23790837/what-is-byte-alignment-cache-line-alignment-for-core-animation-why-it-matters
    // 2. https://stackoverflow.com/questions/15935074/why-is-my-images-bytes-per-row-more-than-its-bytes-per-pixel-times-its-width
    //-----------------------------------------------------------------------------
    
    func decompress(image: UIImage) -> CGImage? {
        //查询当前UIImage的【解压缩前】位图
        guard let cgImage = image.cgImage else {return nil}
        //查询当前位图的Information
        let imageInfo = cgImage.alphaInfo
        var drawInfoRaw = CGImageByteOrderInfo.orderDefault.rawValue
        switch imageInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            drawInfoRaw |= CGImageAlphaInfo.first.rawValue
        default:
            drawInfoRaw |= CGImageAlphaInfo.noneSkipFirst.rawValue
        }
        //创建上下文(画布)
        // 1. 创建的过程中相当于重新绘制了一遍
        // 2. 重新绘制就相当于变相的解压缩了
        let context = CGContext(data: nil, width: cgImage.width, height: cgImage.height , bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: drawInfoRaw)
        //生成解压缩后的位图返回
        return context?.makeImage()
    }
    
    
    //-----------------------------------------------------------------------------
    //MARK: 优化9: 图像绘制(！！重要！！)
    // 核心思路:
    // 减少在主线程的CPU调用，把能在全局线程工作的内容尽量放入全局线程
    //
    // 简单的GCD版本
    // 1. 切换到全局线程创建Bitmap
    // 2. 切换到主线程对layer赋值
    //
    // YYKit、AsyncDrawKit思路
    // 1. 继承CALayer override diaplay方法【目的是使用自己异步绘制，避开主线程】
    // 2. AsyncNode计算Frame、Bound等
    // 3. 通过CATransaction统一提交至主线程的Runloop 让其在CoreAnimation的优先级(2000000)之后运行
    //-----------------------------------------------------------------------------
    // 简单的GCD
    //-----------------------------------------------------------------------------
    func drawGCD() {
        DispatchQueue.global().async {
            // 构造位图并且返回CGImage
            DispatchQueue.main.async {
                // 设置CGImage给 layer.contents
            }
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: CustomLayer + Runloop + Node
    //-----------------------------------------------------------------------------
    // 重写 layerClass 方法告诉View用哪个Layer
    // YYKit:
    // https://github.com/ibireme/YYAsyncLayer/blob/master/YYAsyncLayer/YYAsyncLayer.m
    // 1. 使用了YYAsyncLayerDisplayTask这个对象，通过block把绘制内容委托给了 UIView 从而达到通用
    // 2. DisplayTask 的Block入参传入了
    //    a. 自己开辟的 Size 同 self.bounds 的 Context
    //    b. opaque 不透明度
    //    c. scale 通过UIScreen获得的
    // 3. 如果是不复用的Layer，可以通过 SGCALayer.node 对象保存所有的CPU计算结果用于重写后的display方法
    //-----------------------------------------------------------------------------
    override class var layerClass: AnyClass { return SGCALayer.self }
    
    //-----------------------------------------------------------------------------
    // 添加Runloop进行统一绘制
    // YYKit:
    // 1. YYKit使用了一个 YYTransaction 对象保存了所有需要CPU绘制的操作的target+selector
    // 2. 同时引入了一个计数器 YYSentinel 每次setNeedsDisplay()都会 +1
    // 3. 在开始逃逸主线程时候Capture一个 sentinel.count
    // 4. 在绘制线程对比 sentinel.count 和 Capture时的count是否一致
    // 5. 不一致则认为这次绘制已经过期了，直接放弃，用于提升绘制性能
    //
    // 此处
    // 1. 放弃 Transaction 和 Sentinel 计数导致每次绘制无法进行有效性检查
    // 2. 也就是说如果有10次绘制 YYKit可以做到直接放弃前9次
    // 3. 此处只能保证在Runloop最后提交，还是要绘制10次
    //-----------------------------------------------------------------------------
    func runloopObserverDraw() {
        //获取主线程Runloop
        let mainRunloop = CFRunLoopGetMain()!
        // 以最低优先级加入Observer
        // 并且在Runloop的两个阶段的最后
        // a. beforeWaiting
        // b. exit
        // 触发绘制方法
        let drawAction = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue | CFRunLoopActivity.exit.rawValue , true, CFIndex(INT_MAX)) { [weak self](observer, activity) in
            //保证在当前Runloop的所有事件后(包含CoreAnimation)执行layer的dislay方法
            // YYKit写了一句很奇怪的 super.contents = super.contents 可能不这么写会Crash吧
            self?.layer.setNeedsDisplay()
        }!
        CFRunLoopAddObserver(mainRunloop, drawAction, CFRunLoopMode.commonModes)
    }
    
    //-----------------------------------------------------------------------------
    // MARK: 考点: CoreImage CoreText CoreGraphics 的关系
    // 架构关系:
    //      CoreText
    //         |
    //    CoreGraphics
    //         |
    //      CoreImage
    //-----------------------------------------------------------------------------
    
}
