//
//  SGHitTestView.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGHitTestView: UIView {
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return super.point(inside: point, with: event)
    }
}
