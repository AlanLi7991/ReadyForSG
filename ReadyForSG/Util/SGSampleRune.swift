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
    var decription: String = ""
    
    init(title: String, controller: UIViewController.Type) {
        self.title = title
        self.clazz = controller
        super.init()
    }
    
    convenience init(controller: UIViewController.Type) {
        let title = NSStringFromClass(controller).split(separator: ".").last!
        self.init(title: String(title), controller: controller)
    }
    
    
}
