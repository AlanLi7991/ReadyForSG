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
        self.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("hitTest point ( \(String(format: "%0.2f", point.x)) , \(String(format: "%0.2f", point.y)) )")
        return super.hitTest(point, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("point inside point ( \(String(format: "%0.2f", point.x)),\(String(format: "%0.2f", point.y)) )")
        return super.point(inside: point, with: event)
    }
}
