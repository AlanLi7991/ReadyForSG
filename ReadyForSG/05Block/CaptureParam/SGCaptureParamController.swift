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
//      1. __strong: 强引用对象
//      2. __weak：弱引用对象，如果对象被释放，会置为nil
//      3. __unsafe_unretained(在swift叫unowned)：指针指向对象，当对象被释放掉时，会变成野指针
//      4. __autoreleasing：告诉编译器，此对象在autorelease pool结束的时候，才释放对象
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
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Block"
        return rune
    }
}
