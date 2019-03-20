//
//  SGOffScreenLayer.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/18.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------------------
// MARK: 离屏幕渲染
//
// 离屏幕渲染的定义:
// 1. 在当前屏幕缓冲区(Context)之外开辟新的缓冲区进行绘制
// 2. 开辟新的缓冲区是指的 Context 的实例化
// 3. 离屏幕渲染既可以在CPU完成也可以在GPU完成
// 4. 离屏渲染并不特别消耗性能，而是GPU切换上下文特别消耗性能
//
// 重点参考文章:
// https://lobste.rs/s/ckm4uw/a_performance-minded_take_on_ios_design
// 其余参考
// http://foggry.com/blog/2015/05/06/chi-ping-xuan-ran-xue-xi-bi-ji/
// https://objccn.io/issue-3-1/
//
// 核心段落1
//-----------------------------------------------------------------------------
// In particular, a few (implementing drawRect and doing any CoreGraphics drawing
// drawing with CoreText [which is just using CoreGraphics]) are indeed “offscreen drawing
// but they’re not what we usually mean when we say that.
// When you implement drawRect or draw with CoreGraphics
// you’re using the CPU to draw, and that drawing will happen synchronously within your application
// You’re just calling some function which writes bits in a bitmap buffer, basically.
// The other forms of offscreen drawing happen on your behalf
// in the render server (a separate process) and are performed via the GPU
//
//
// 1. 在drawRect里调用CG接口以及启动一个单独GPU渲染进程(process)来进行图像合成都可以叫 “离屏渲染”
// 2. 我们通常说的避免 “离屏渲染” 指的是后者 原因见段落2
// 3. drawRect的情况，因为此时在使用CPU处理，并且是同步与主线程(synchronously within your application)
// 4. 第3点 可以简单点称为调用了一些自定义绘制方法，虽然开辟了新的Context，确实符合离屏渲染定义
//-----------------------------------------------------------------------------
//
// 核心段落2
//
//-----------------------------------------------------------------------------
// You’d think the GPU would always be faster than the CPU at this sort of thing
// but there are some tricky considerations here.
// It’s expensive for the GPU to switch contexts from on-screen to off-screen drawing
// (it must flush its pipelines and barrier)
// so for simple drawing operations, the setup cost may be greater than
// the total cost of doing the drawing in CPU via e.g. CoreGraphics would have been.
//
// 1. 大部分人会觉得GPU处理的就是比CPU快，这个观点是错误的
// 2. 对于GPU来说，从一个Context切换到另外一个Context是消耗十分大的
// 3. 步骤2的消耗对于GPU来讲，可能比整个绘制过程还要大
// 4. 好巧不巧 CoreGraphics 的离屏渲染就是3描述的这么挫，所以要避免
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// MARK: 什么是上下文切换(Context switch)
//
// 参考:
// https://en.wikipedia.org/wiki/Context_switch
// https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#context
//
// Wiki原文重点
// In computing, a context switch is the process of storing the state of a process or of a thread
// so that it can be restored and execution resumed from the same point later.
// This allows multiple processes to share a single CPU
// and is an essential feature of a multitasking operating system.
//
// 1. 上下文切换是指把当前的硬件状态保存在某一块内存
// 2. 保存的作用是让当前的操作是可恢复继续执行的
// 3. 最开始的时候是为了使用单核来进行多任务
// 4. 后来变成了多任务的核心
//
// 补充知识点:
// 1. 上下文(Context)是对硬件状态的描述
// 2. 分为软件切换和硬件切换(早期)
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// MARK: CoreGraphics何时触发离屏渲染
// 1. shouldRasterize（光栅化）
// 2. mask（遮罩）
// 3. shadow 相关(阴影)
// 4. allowsEdgeAntialiasing（抗锯齿）
// 5. cornerRadius (圆角)
// 6. opacity < 1 (不透明)
//
// 综上所述凡是去要处理 Alpha通道(opacity、mask)，或者说需要合成的操作(阴影、圆角) 都会调用GPU去离屏渲染
// 由于CoreGraphics默认在主线程，所以很可能导致当前操作大于16.67ms，导致错过下一个VSync信号，产生掉帧
//
// 这也说明了为什么需要设置 isOpaque 为true，可以直接跳过Alpha通道渲染提升性能
//
// 参考
// https://www.jianshu.com/p/6d24a4c29e18
// iOS 9.0 之前UIimageView跟UIButton设置圆角都会触发离屏渲染
// iOS 9.0 之后UIButton设置圆角会触发离屏渲染
// 而UIImageView里png图片设置圆角不会触发离屏渲染了，如果设置其他阴影效果之类的还是会触发离屏渲染的。
//
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// MARK: 光栅化(shouldRasterize)的原理
//-----------------------------------------------------------------------------
// 光栅化是什么
// 参考Wiki
// https://en.wikipedia.org/wiki/Rasterisation
// A series of pixels, dots or lines that when they come together on a display, they recreate the image
// 就是把一张图片重新绘制成一个一个的像素点
//-----------------------------------------------------------------------------
// 核心段落3
//-----------------------------------------------------------------------------
//
// If any of the latter are triggered, there’s no caching
// and offscreen drawing will happen on every frame;
// rasterization does indeed require an offscreen drawing pass,
// but so long as the rasterized layer’s sublayers aren’t changing,
// that rasterization will be cached and repeated on each frame.
// And of course, if you’re using drawRect: or drawing yourself via CG
// you’re probably caching locally.
// More on this in “Polishing Your Rotation Animations,” WWDC 2012.
//
// 1. 光栅化会开启一个Context作为缓存区域
// 2. 如果变化不大，会直接复用缓存
// 3. 如果你自己使用CG接口绘制，也可以自己缓存和光栅化一个意思
//
// 结论
// 1. 如果经常变化的Bitmap就不要开启光栅化了，因为缓存总变没啥用
// 2. 不经常变化的Bitmap可以开启光栅化，使用缓存降低GPU压力
// 3. 光栅化是使用CPU完成的，所以有些文章说是使用CPU分摊GPU的压力
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// MARK: 如何检查离屏渲染
//-----------------------------------------------------------------------------


class SGOffScreenLayer: UIView {

    func offScreenRender() {
//        layer.cornerRadius
//        layer.allowsEdgeAntialiasing
//        layer.shadowRadius
//        layer.shouldRasterize
//        layer.opacity
//        self.isOpaque
    }
}
