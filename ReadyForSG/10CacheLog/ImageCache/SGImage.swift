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

    private let map = NSMapTable<NSString, UIImage>.strongToWeakObjects()
    private let cache = NSCache<NSString, UIImage>()
    private let disk = SGDisk<NSString, UIImage>()
    
    let key: NSString
    let render: SGImageRender
    
    init(key: String, reder: @escaping SGImageRender) {
        self.key = NSString(string: key)
        self.render = reder
        super.init()
        
        cache.name = "SGImageCache"
        cache.totalCostLimit = 100
        
        disk.name = "SGImageDisk"
    }
    
    var image: UIImage? {
        get {
            
            return fetchImage()
        }
        set {
            if newValue != nil {
                storeImage(newValue!)
            }
        }
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
                self?.image = img
                DispatchQueue.main.async { [weak self] in
                    self?.render(img)
                }
            }.resume()
            sleep(1)
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
    
    private func fetchImage() -> UIImage? {
        if let image = map.object(forKey: key) {
            return image
        }
        if let image = cache.object(forKey: key) {
            return image
        }
        if let image = disk.object(forKey: key) {
            return image
        }
        reload()
        return nil
    }
    
    private func storeImage(_ image: UIImage) {
        DispatchQueue.global().async { [weak self] in
            guard let target = self else { return }
            target.map.setObject(image, forKey: target.key)
            target.cache.setObject(image, forKey: target.key, cost: 1)
            target.disk.setObject(image, forKey: target.key)
        }
    }
    
}
