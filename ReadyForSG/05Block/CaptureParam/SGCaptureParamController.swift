//
//  SGCaptureParamController.swift
//  ReadyForSG
//
//  Created by Vince.Zheng on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

////////////////////////////// 静态局部变量 //////////////////////////////
//MARK: 静态局部变量
//
//  对于静态局部变量，在swift时，只能存在于类中，而无法存储于方法内执行，会报错：Static properties may only be declared on a type
//  比如 addStaticLocalVar 的方法，但是在OC中是可以这么写的
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// 局部变量 //////////////////////////////
//MARK: 局部变量
//  提前先知道的修饰符类型：
//      1. __strong(OC/Swift): 强引用对象, 在ARC模式下使用的，在MRC与retain想对应，可引起对象的引用计数+1
//      2. __weak(OC/Swift)：弱引用对象，如果对象被释放，会置为nil
//      3. __unsafe_unretained(在swift叫unowned)：指针指向对象，当对象被释放掉时，会变成野指针
//      4. __autoreleasing(OC)：告诉编译器，此对象在autorelease pool结束的时候，才释放对象
//      5. assign(OC)：修饰非对象类型和基础数据类型的属性，不涉及内存管理，因此也不会被引用计数
//      6. copy(OC)：创建一个新的对象，新对象的引用计数+1，但不会改变原来的对象的引用计数
//      7. nonatomic(OC)：和atomic相对，是非原子性操作，非线程安全
//      8. atomic(OC)：原子性操作，线程安全，但是会影响性能
//      9. readwrite(OC)：可读可写，getter/setter
//      10. readonly：可读不可写，getter
//      11. writeonly：可写不可读，setter
//
//  区别知识点：
//      1. strong & copy的区别使用：https://juejin.im/post/5b6be76b6fb9a04fdf3a099d
//
//  拓展知识：
//  Swift 访问权限修饰符：
//      1.open: 可以被任何模块访问到，可以在任何模块被子类化 or 重写
//      2.public: 可以被任何模块访问到，只能在当前模块被子类化 or 重写
//      3.internal: 只有在本模块内可以访问到
//      4.fileprivate: 只有同一个文件内的才能访问到，比如在同一个文件下，声明了extension
//      5.private: 只有类内部能访问，在extension中并不能访问
//
//  Swift所有权宣言（可以找时间细读，关于swift的内存处理的优化）：https://onevcat.com/2017/02/ownership/
///////////////////////////////////////////////////////////////////////

////////////////////////////// Block的结构 //////////////////////////////
//
//  还是可以的介绍Block结构是怎样：http://liuduo.me/2018/02/19/block-impl/
//  struct __block_impl {
//      void *isa;
//      int Flags;
//      int Reserved;
//      void *FuncPtr;
//  };
//
//  _block_impl_0：总的struct结构(__block_impl, _block_desc_0, capture的变量）
//  _block_func_0: block内的实现函数
//  _block_desc_0: 关于block的基本信息（内存占多少，copy的函数指针，dispose函数指针）
//
//  _Block_object_assign: 会对对象引用计数加1 (https://juejin.im/post/5b29f5f56fb9a00e985f2e1a)
//  _Block_object_dispose: 销毁对象
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// Block截获变量方式 //////////////////////////////
//
//  静态全局变量，全局变量：不会截获，它都全局可以拿到，截获又有什么意义
//  局部变量: 基础数据类型，只是进行值传递。对象类型，把整个指针存起来（即连所有权修饰符都获取了）
//      【进阶】静态局部变量：通过保存其地址的方式，存储变量。（指针的指针，保持对象类型。指针，保存基础类型（int，float等））
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// __block修饰符 //////////////////////////////
//
//  什么时候需要__block修饰符
//  静态全局变量，全局变量：不会截获，它都全局可以拿到，截获又有什么意义
//  局部变量: 基础数据类型，只是进行值传递。对象类型，把整个指针存起来（即连所有权修饰符都获取了）
//      【进阶】静态局部变量：通过保存其地址的方式，存储变量。（指针的指针，保持对象类型。指针，保存基础类型（int，float等））
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// clang基本使用 //////////////////////////////
//
//  编译过程讲解：《Compilers: Principles, Techniques, and Tools》龙书
//
//  clang: 官网介绍 https://clang.llvm.org/index.html
//  clang的由来：https://juejin.im/post/5b238f5be51d45587f49f380
//  1. AST信息可序列化，供IDE更强操控代码(代码补全，重构）
//  2. 可以做到动态检查，以往都是静态检查
//
//  可以使用以下的指令，把SGStaticParam文件 转化成 C++语言
//  比如：xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-9.0.0 -stdlib=libc++ SGStaticParam.m
//  xcrun -sdk iphoneos用于查找到iPhone真机的库
//  fobjc-runtime=<value>: Specify the target Objective-C runtime kind and version
//
//  gcc编译过程: http://chengqian90.com/C%E8%AF%AD%E8%A8%80/GCC%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3.html
//  源文件=》预处理（cpp）=》纯C=》编译器=》汇编程序=》汇编器=》目标文件=》链接器=》可执行文件
//
//  gcc 与 clang 的区别：http://www.voidcn.com/article/p-rtbcbgcs-bms.html
//
//  LLVM三层式架构：(https://objccn.io/issue-6-2/【重点可以看下，预编译优化，如何构建自己clang】)
//      1.前端语言的转化(clang)
//      2.共享式的优化器（LLVM IR【LLVM Intermediate Representation(LLVM 中间表达码)】做优化）
//      3.将中间表达码，转化成目标平台文件
//
///////////////////////////////////////////////////////////////////////

////////////////////////////// 面试题 //////////////////////////////
//
//  __block在ARC，MRC的区别：https://ioscaff.com/articles/276
//  assign vs weak, __block vs __weak区别：https://www.jianshu.com/p/2aacbc9c66df
//
///////////////////////////////////////////////////////////////////////

class SGCaptureParamController: UIViewController {
    
    static var staticLocalVar = 1;

    let action = SGActionRune()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        action.attach(viewController: self)
        action.alert.addAction(UIAlertAction(title: "autoreleasing修饰符", style: .default, handler: { [weak self](_) in
            self?.autoreleasingModifier()
        }))
        action.alert.addAction(UIAlertAction(title: "swift静态局部变量实现", style: .default, handler: { [weak self](_) in
            self?.addStaticLocalVar()
        }))
        action.alert.addAction(UIAlertAction(title: "oc各种静态变量捕获", style: .default, handler: { [weak self](_) in
            self?.ocCaptureFunctionCall();
        }))
    }
    
    func ocCaptureFunctionCall() -> Void {
        let test = SGStaticParam();
        test.captureStaticGlobalVar();
    }
    
    func autoreleasingModifier() {
        // 以下的写法会crash，因为b在跑出作用域时，已经销毁了
//        unowned var a : NSObject;
//
//        do {
//            var b = NSObject();
//            a = b;
//        }
//
//        print(a);
        
        let test = SSAutoreleasingTest();
        test.testAutoreleasing();
    }
    
    func addStaticLocalVar() {
        // Error: Static properties may only be declared on a type
        // static var base = 0
        struct Temp {
            static var base = 0
        }
        // 就是swift版的 static局部变量，需要跟着一个struct or class
        
        Temp.base += 1
        print("static local Variable \(Temp.base)")
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Block"
        return rune
    }
}
