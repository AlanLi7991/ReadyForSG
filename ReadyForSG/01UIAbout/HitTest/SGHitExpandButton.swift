//
//  SGHitExpandButton.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGHitExpandButton: UIButton {
    
    var count = 0
    
    convenience init() {
        self.init(type: .system)
        setTitle("Click", for: .normal)
        setTitleColor(UIColor.black, for: .normal)
        backgroundColor = UIColor.red.withAlphaComponent(0.2)
        addTarget(self, action: #selector(didTouchInside), for: .touchUpInside)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = self.bounds.insetBy(dx: -50, dy: -20)
        if rect.contains(point) {
            return self
        }
        return super.hitTest(point, with: event)
    }
    
    @objc func didTouchInside() {
        count += 1
        setTitle(String(count), for: .normal)
    }
    
}
