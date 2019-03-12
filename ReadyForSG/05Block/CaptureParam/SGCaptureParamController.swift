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
//  拓展知识：
//  Swift 访问权限修饰符：
//      1.open: 可以被任何模块访问到，可以在任何模块被子类化 or 重写
//      2.public: 可以被任何模块访问到，只能在当前模块被子类化 or 重写
//      3.internal: 只有在本模块内可以访问到
//      4.fileprivate: 只有同一个文件内的才能访问到，比如在同一个文件下，声明了extension
//      5.private: 只有类内部能访问，在extension中并不能访问
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
