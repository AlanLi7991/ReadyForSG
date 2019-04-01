//
//  SGGCDRunes.swift
//  ReadyForSG
//
//  Created by vince on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGGCDRunes: SGSampleRunes {
    
    convenience init() {
        self.init(title: "GCD")
    }
    
    override func runesInSect() -> [SGSampleRune] {
        return [SGOperationQueueViewController.rune(),
                SGGCDViewController.rune(),
                SGNSThreadViewController.rune(),
                SGLockViewController.rune()]
    }
}
