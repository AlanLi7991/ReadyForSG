//
//  SGImageController.swift
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/24.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

import UIKit

class SGImageCell: UITableViewCell {
    
    var cache: SGImage?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cache = SGImage(key: reuseIdentifier!) { [weak self] (image) in
            self?.imageView?.image = image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SGImageController: UITableViewController {
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "\(indexPath.row)") as? SGImageCell
        if cell == nil {
            cell = SGImageCell(style: .default, reuseIdentifier: "\(indexPath.row)")
        }
        cell!.imageView?.image = cell!.cache?.image
        cell!.textLabel?.text = "\(indexPath.row)"
        return cell!
    }

    static func rune() -> SGSampleRune {
        let rune = SGSampleRune(controller: self)
        rune.decription = "Image Cache Table"
        return rune
    }
}
