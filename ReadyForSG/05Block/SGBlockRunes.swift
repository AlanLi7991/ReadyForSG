//
//  SGBlockRunes.swift
//  ReadyForSG
//
//  Created by Vince.Zheng on 2019/3/9.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGBlockRunes: SGSampleRunes {
    convenience init() {
        self.init(title: "Block")
    }
    
    override func runesInSect() -> [SGSampleRune] {
        return [
            SGCaptureParamController.rune(),
        ];
    }
}
