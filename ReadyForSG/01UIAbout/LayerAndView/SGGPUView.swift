//
//  SGGPUView.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/15.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------------------
// MARK: GPU优化的注意点
//参考:
//https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/
//-----------------------------------------------------------------------------
class SGGPUView: UIView {

    //-----------------------------------------------------------------------------
    //MARK: 优化1: 纹理的渲染(不重要)
    // 1. iOS处理GPU渲染的纹理(Texture)有大小限制，最大4096，所以图片最好不要超过
    // 2. 参考http://iosres.com
    //-----------------------------------------------------------------------------

    
    //-----------------------------------------------------------------------------
    //MARK: 优化2: 视图的混合Composing(不重要)
    // 1. 多个UIView叠加的时候，GPU需要把他们的Layer都Compose到一起才能显示出来效果
    // 2. 通过设置 isOpaque 可以减少不必要的Alpha计算，直接跳过
    //-----------------------------------------------------------------------------
    func disableOpacity() {
        isOpaque = true
    }
    
    
    //-----------------------------------------------------------------------------
    //MARK: 优化3: 图形的生成(！！重要！！)
    // 1. 离屏渲染的触发条件
    // 2. 光栅化的原理
    // 3. 离屏渲染的为什么会卡顿
    //
    // 参考 SGOffScreenLayer 文件详细说明
    //-----------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------
    // MARK: 何时使用CPU何时使用CPU
    // 1. 由CoreImage决定
    // 2. 有CIContext的实例化方法决定，注意平时我们用的都是CG
    //
    // 创建基于 CPU 的 CIContext 对象 (默认是基于 GPU，CPU 需要额外设置参数)
    // context = [CIContext contextWithOptions: [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kCIContextUseSoftwareRenderer]];
    // 创建基于 GPU 的 CIContext 对象
    // context = [CIContext contextWithOptions: nil];
    // 创建基于 GPU 的 CIContext 对象
    // EAGLContext *eaglctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // context = [CIContext contextWithEAGLContext:eaglctx];
    // 参考:
    // https://colin1994.github.io/2016/10/21/Core-Image-OverView/
    // https://www.jianshu.com/p/13a28228f25f
    //-----------------------------------------------------------------------------
}
