//
//  ImageCache.swift
//  ReadyForSG
//
//  Created by Elliot Li on 3/19/19.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

public class SGImageCache: NSObject {
    
    typealias SGImageRender = (String, UIImage) -> Void

    private var map: NSMapTable<NSString, UIImage>? = nil
    private let cache = NSCache<NSString, UIImage>()
    private let disk = SGDisk<NSString, UIImage>()
    
    let render: SGImageRender
    public var useMap: Bool = false {
        didSet {
            if useMap {
                map =  NSMapTable<NSString, UIImage>.strongToWeakObjects()
            }else {
                map = nil
            }
        }
    }
    
    init(reder: @escaping SGImageRender) {
        self.render = reder
        super.init()

        cache.name = "SGImageCache"
        cache.totalCostLimit = 30
        
        disk.name = "SGImageDisk"
    }
    
    func cleanMap() {
        map?.removeAllObjects()
    }
    
    func cleanCache() {
        cache.removeAllObjects()
    }
    
    func cleanDisk() {
        disk.removeAllObjects()
    }
    
    //-----------------------------------------------------------------------------
    // MARK: Getter Setter
    //-----------------------------------------------------------------------------
    
    public func fetchImage(key: String) -> (UIImage, String) {
        let oc_key = key as NSString
        let file_key = key.appending(".jpeg") as NSString
        
        if let image = map?.object(forKey: oc_key) {
            return (image, "[\(key)] from MapTable[\(map?.count ?? 0)])")
        }
        if let image = cache.object(forKey: oc_key) {
            restore(key: key, image: image)
            return (image, "[\(key)] from NSCache[\(cache.totalCostLimit)])")
        }
        if let image = disk.object(forKey: file_key) {
            restore(key: key, image: image)
            return (image, "[\(key)] from Disk[])")
        }
        reload(key: key)
        return (UIImage(), "[\(key)] from Internet[])")
    }
    
    private func reload(key: String) {
        DispatchQueue.global().async { [weak self] in
//            guard let url = URL(string: "https://source.unsplash.com/random") else {
            guard let url = URL(string: "https://uploadbeta.com/api/pictures/random/?key=BingEverydayWallpaperPicture") else {
                print("create url error...")
                return
            }
            URLSession.shared.dataTask(with: url) { [weak self](data, res, err) in
                guard let imageData = data else { return }
                guard let img = UIImage(data: imageData) else { return }
                self?.store(key: key, image: img)
                DispatchQueue.main.async { [weak self] in
                    self?.render(key, img)
                }
                }.resume()
        }
    }
    
    private func store(key: String, image: UIImage) {
        DispatchQueue.global().async { [weak self] in
            let oc_key = key as NSString
            let file_key = key.appending(".jpeg") as NSString
            
            guard let target = self else { return }
            target.map?.setObject(image, forKey: oc_key)
            target.cache.setObject(image, forKey: oc_key, cost: 1)
            target.disk.setObject(image, forKey: file_key)
        }
    }
    
    private func restore(key: String, image: UIImage) {
        DispatchQueue.global().async { [weak self] in
            let oc_key = key as NSString
            
            if self?.map?.object(forKey: oc_key) == nil {
                self?.map?.setObject(image, forKey: oc_key)
            }
            if self?.cache.object(forKey: oc_key) == nil {
                self?.cache.setObject(image, forKey: oc_key, cost: 1)
            }
        }
    }
    
}
