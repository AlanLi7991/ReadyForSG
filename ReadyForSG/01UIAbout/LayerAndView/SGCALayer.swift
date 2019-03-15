//
//  SGCALayer.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/14.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGCALayer: CALayer {

    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        print("CALayer: setNeedsDisplay)")
    }
    
    override func setNeedsDisplay(_ r: CGRect) {
        super.setNeedsDisplay(r)
        print("CALayer: setNeedsDisplay(_ rect:)")
    }
    
}
