//
//  SGObjectS.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/9.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGObjectS: NSObject {
    
    override class func resolveInstanceMethod(_ sel: Selector!) -> Bool {
        let result = super.resolveInstanceMethod(sel)
        print("Swift: [resolveInstanceMethod:] SEL \(NSStringFromSelector(sel)) result \(result)")
        return result
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        let result: Any? = super.forwardingTarget(for: aSelector)
        print("Swift: [forwardingTarget:] SEL \(NSStringFromSelector(aSelector)) result \(String(describing: result))")
        return result
    }

    override func doesNotRecognizeSelector(_ aSelector: Selector!) {
        print("Swift: [doesNotRecognizeSelector:] SEL \(NSStringFromSelector(aSelector))")
        super.doesNotRecognizeSelector(aSelector)
    }

}
