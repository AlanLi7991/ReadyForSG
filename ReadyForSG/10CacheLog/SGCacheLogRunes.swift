//
//  SGCacheLogRunes.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGCacheLogRunes: SGSampleRunes {
    
    
    convenience init() {
        self.init(title: "CacheImage & Log")
    }
    
    override func runesInSect() -> [SGSampleRune] {
        return [
            SGImageController.rune(),
        ]
    }
    
}
