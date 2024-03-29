//
//  GOBSampleRune.swift
//  GateOfBabylon
//
//  Created by Zhuojia on 2019/2/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGSampleRune: NSObject {
    
    let title: String
    let clazz: UIViewController.Type
    @objc public var decription: String = ""
    
    @objc public init(title: String, controller: UIViewController.Type) {
        self.title = title
        self.clazz = controller
        super.init()
    }
    
    @objc public convenience init(controller: UIViewController.Type) {
        let title = NSStringFromClass(controller).split(separator: ".").last!
        self.init(title: String(title), controller: controller)
    }
    
    
}
