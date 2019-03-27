//
//  SGImageController.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGImageController: UITableViewController {
    
    let action = SGActionRune();
    var cache: SGImageCache?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cache = SGImageCache() { [weak self](key, image) in
            guard let indexes = self?.tableView.indexPathsForVisibleRows else { return }
            indexes.forEach({ [weak self] (index) in
                if key == "\(index.section)\(index.row)" {
                    self?.tableView.cellForRow(at: index)?.setNeedsLayout()
                }
            })
        }
        
        action.attach(viewController: self)
        
        action.alert.addAction(UIAlertAction(title: "Use MapTable", style: .default, handler: { [weak self](it) in
            self?.cache?.useMap = !(self?.cache?.useMap ?? true)
        }))
        
        action.alert.addAction(UIAlertAction(title: "Clean Map", style: .default, handler: { [weak self](it) in
            self?.cache?.cleanMap()
        }))
        
        action.alert.addAction(UIAlertAction(title: "Clean Cache", style: .default, handler: { [weak self](it) in
            self?.cache?.cleanCache()
        }))
        
        action.alert.addAction(UIAlertAction(title: "Clean Disk", style: .default, handler: { [weak self](it) in
            self?.cache?.cleanDisk()
        }))
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SGImageCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SGImageCell")
        }
        let render = cell!
        guard let source = cache else {
            return render
        }
        autoreleasepool {
            let key = "\(indexPath.section)\(indexPath.row)"
            let tuple = source.fetchImage(key: key)
            render.textLabel?.text = key
            render.imageView?.image = tuple.0
            render.detailTextLabel?.text = tuple.1
        }
        
        return render
        
    }

    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Image Cache Table"
        return rune
    }
}
