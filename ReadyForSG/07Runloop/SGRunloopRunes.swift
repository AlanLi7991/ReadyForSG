//
//  SGRunloopRunes.swift
//  ReadyForSG
//
//  Created by 郑森垚 on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGRunloopRunes: SGSampleRunes {
    convenience init() {
        self.init(title: "Runloop")
    }
    
    override func runesInSect() -> [SGSampleRune] {
        return [
            SGMainThreadStuttersMonitorController.rune()
        ]
    }
}
