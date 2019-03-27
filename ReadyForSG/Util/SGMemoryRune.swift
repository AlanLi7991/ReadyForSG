//
//  SGMemoryRune.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/25.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit


//-----------------------------------------------------------------------------
// MARK: 获取当前内存
// https://forums.developer.apple.com/thread/64665
// Lines 1…3 expose mach_task_self_ via a function-based wrapper, as you’d expect in C.
// Line 6 declares the output buffer on the stack as the correct type, mach_task_basic_info.
// Line 7 calculates its size in terms of integer_t, which is how Mach IPC counts.
// Line 8 gets its address as an UnsafeMutablePointer<mach_task_basic_info>.
// Line 9 reinterprets that as a contiguous array of integer_t, which is what Mach IPC wants.
//-----------------------------------------------------------------------------
class SGMemoryRune: NSObject {
    
    var timer: Timer? = nil
    public var isActive: Bool {
        return timer?.isValid ?? false
    }
    
    func active() {
        guard let t = timer else {
            timer = Timer(timeInterval: 1.0, repeats: true, block: { (timer) in
                
            })
        }
        t
    }
    
    func invalid() {
        
    }

    func mach_task_self() -> task_t {
        return mach_task_self_
    }
    
    func getMegabytesUsed() -> Float? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                return task_info(
                    mach_task_self(),
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return nil
        }
        return Float(info.resident_size) / (1024 * 1024)
    }
}
