//
//  SGHitEmptyContainer.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGHitEmptyContainer: UIView {

    convenience init() {
        self.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }
    
}
