//
//  ImageCache.swift
//  ReadyForSG
//
//  Created by Elliot Li on 3/19/19.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

public class SGImage: NSObject {
    
    typealias SGImageRender = (UIImage) -> Void
    typealias SGImageInfo = (String) -> Void

    private let map = NSMapTable<NSString, UIImage>.weakToWeakObjects()
    private let cache = NSCache<NSString, UIImage>()
    private let disk = SGDisk<NSString, UIImage>()
    
    let key: NSString
    let render: SGImageRender
    let info: SGImageInfo
    
    init(key: String, reder: @escaping SGImageRender, info: @escaping SGImageInfo) {
        self.key = NSString(string: key)
        self.render = reder
        self.info = info
        super.init()
        
        cache.name = "SGImageCache"
        cache.totalCostLimit = 5
        
        disk.name = "SGImageDisk"
    }
    
    func reload() {
        clean()
        DispatchQueue.global().async { [weak self] in
            guard let url = URL(string: "https://source.unsplash.com/random") else {
                print("create url error...")
                return
            }
            URLSession.shared.dataTask(with: url) { [weak self](data, res, err) in
                guard let imageData = data else { return }
                guard let img = UIImage(data: imageData) else { return }
                self?.storeImage(img)
                DispatchQueue.main.async { [weak self] in
                    self?.render(img)
                }
            }.resume()
        }
    }
    
    func clean() {
        map.removeObject(forKey: key)
        cache.removeObject(forKey: key)
        disk.removeObject(forKey: key)
    }
    
    //-----------------------------------------------------------------------------
    // MARK: Getter Setter
    //-----------------------------------------------------------------------------
    
    public func fetchImage() -> (UIImage?, String) {
        if let image = map.object(forKey: key) {
            return (image, "[\(key)] from MapTable[\(map.keyEnumerator().allObjects.count)])")
        }
        if let image = cache.object(forKey: key) {
            restoreCache(image, fromDisk: false)
            return (image, "[\(key)] from NSCache[\(cache.totalCostLimit)])")
        }
        if let image = disk.object(forKey: key.appending(".jpeg") as NSString) {
            restoreCache(image, fromDisk: true)
            return (image, "[\(key)] from Disk[*])")
        }
        reload()
        return (nil, "[\(key)] from Internet[*])")
    }
    
    private func storeImage(_ image: UIImage) {
        DispatchQueue.global().async { [weak self] in
            guard let target = self else { return }
            target.map.setObject(image, forKey: target.key)
            target.cache.setObject(image, forKey: target.key, cost: 1)
            target.disk.setObject(image, forKey: target.key.appending(".jpeg") as NSString)
        }
    }
    
    private func restoreCache(_ image: UIImage, fromDisk: Bool) {
        DispatchQueue.global().async { [weak self, fromDisk] in
            guard let target = self else { return }
            target.map.setObject(image, forKey: target.key)
            if fromDisk {
                target.cache.setObject(image, forKey: target.key, cost: 1)
            }
        }
    }
    
}
