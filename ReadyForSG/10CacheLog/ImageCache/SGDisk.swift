//
//  SGDisk.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGDisk<KeyType, ObjectType> : NSObject where KeyType : NSString, ObjectType : UIImage {

    open var name: String = "SGDisk" {
        didSet {
            makeDirectory()
        }
    }
    
    var directory: URL? = nil
    let fileManager = FileManager.default

    override init() {
        super.init()
        makeDirectory()
    }
    
    func makeDirectory() {
        directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(name)

        guard let dir = directory else { return }

        do {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    return
                } else {
                    try FileManager.default.moveItem(at: dir, to: dir.appendingPathExtension(".backup"))
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
                }
            }else {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            fatalError("SGDisk makeDirectory failure")
        }
    }
    
    open func object(forKey key: KeyType) -> ObjectType? {
        guard let file = directory?.appendingPathComponent(key as String) else {
            return nil
        }
        if !fileManager.fileExists(atPath: file.path) {
            return nil
        }
        return ObjectType(contentsOfFile: file.path)
    }
    
    open func setObject(_ obj: ObjectType, forKey key: KeyType) {
        guard let file = directory?.appendingPathComponent(key as String) else {
            return
        }
        do {
            if fileManager.fileExists(atPath: file.path) {
                try fileManager.removeItem(at: file)
            }
            try obj.pngData()?.write(to: file, options: .atomicWrite)
        } catch {
            
        }

        
        
    }
    
    open func removeObject(forKey key: KeyType) {
        guard let file = directory?.appendingPathComponent(key as String) else {
            return
        }
        do {
            try fileManager.removeItem(at: file)
        } catch {
            
        }
    }
    
    open func removeAllObjects() {
        guard let dir = directory else { return }
        do {
            try fileManager.removeItem(at: dir)
            makeDirectory()
        } catch  {
            
        }
    }

    
    
}
