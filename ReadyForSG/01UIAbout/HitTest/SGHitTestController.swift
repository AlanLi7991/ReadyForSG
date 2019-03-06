//
//  SGHitTestController.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGHitTestController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = SGHitTestView()
    }
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Hit Test Sample"
        return rune
    }

}
