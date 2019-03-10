//
//  SGRuntimeRunes.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGRuntimeRunes: SGSampleRunes {

    convenience init() {
        self.init(title: "Runtime")
    }
    
    override func runesInSect() -> [SGSampleRune] {
        return [
            SGMessageController.rune(),
            SGMessageControllerS.rune(),
            SGSwizzleController.rune(),
        ]
    }
}
