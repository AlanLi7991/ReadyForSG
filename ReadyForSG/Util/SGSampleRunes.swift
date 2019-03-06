//
//  SGSampleRunes.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGSampleRunes: NSObject {
    
    let title: String

    @objc public init(title: String) {
        self.title = title
        super.init()
    }
    
    var runes: [SGSampleRune] {
        return runesInSect()
    }
    
    func runesInSect() -> [SGSampleRune] {
        return []
    }
}
