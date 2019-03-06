//
//  SGUIAboutRunes.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGUIAboutRunes: SGSampleRunes {
    
    
    convenience init() {
        self.init(title: "UIAbout")
    }
    
    override func runesInSect() -> [SGSampleRune] {
        return [
            SGHitTestController.rune()
        ]
    }

}
