//
//  SGMessageSController.swift
//  ReadyForSG
//
//  Created by Elliot Li on 3/8/19.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGMessageForwardController: UIViewController {

    let action = SGActionRune()
    let obj = SGObject()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        SGLogRune.instance.attach(view: view)
        action.attach(viewController: self)
        
        action.alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { [weak self](_) in
            self?.obj.test()
        }))
        
    }

    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "NSObject MessageForward log"
        return rune
    }
    
}
