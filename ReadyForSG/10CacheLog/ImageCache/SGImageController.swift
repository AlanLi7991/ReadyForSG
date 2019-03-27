//
//  SGImageController.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGImageModel: NSObject {
    
    let index: IndexPath
    let title: String
    var cache: SGImage?
    var table: UITableView? = nil
    
    init(index: IndexPath) {
        self.index = index
        self.title = "\(index.section)-\(index.row)"
        super.init()
        self.cache = SGImage(key: title , reder: { [weak self] (image) in
            
            (self?.table?.reloadRows(at: [self!.index], with: .fade))!
            
            }, info: {_ in
                
        })
    }
    
    
    
}

class SGImageController: UITableViewController {
    
    var data: [IndexPath: SGImageModel] = [IndexPath: SGImageModel]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if data[indexPath] == nil {
            let model = SGImageModel(index: indexPath)
            model.table = tableView
            data[indexPath] = model
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: "SGImageCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SGImageCell")
        }
        guard let model = data[indexPath] else {
            return cell!
        }
        
        let value = model.cache?.fetchImage()
        cell?.imageView?.image = value?.0
        cell?.textLabel?.text = "\(indexPath.row)"
        cell?.detailTextLabel?.text = value?.1
        
        return cell!
    }

    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Image Cache Table"
        return rune
    }
}
