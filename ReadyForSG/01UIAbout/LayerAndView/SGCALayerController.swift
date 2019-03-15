//
//  SGCALayerController.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGCALayerController: UIViewController {

    let action = SGActionRune()
    let red = SGCALayerView(frame: CGRect(x: 200, y: 200, width: 100, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
//        SGLogRune.instance.attach(view: self.view)
        action.attach(viewController: self)
        
        action.alert.addAction(UIAlertAction(title: "Red", style: .default, handler: { [weak self](_) in
            self?.view.addSubview(self!.red)
        }))
        
        action.alert.addAction(UIAlertAction(title: "Clear", style: .destructive    , handler: { [weak self](_) in
            self?.red.removeFromSuperview()
        }))
    }
    
    
    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "CALayer draw log"
        return rune
    }
    
}
