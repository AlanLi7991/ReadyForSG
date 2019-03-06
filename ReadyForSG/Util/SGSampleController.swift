//
//  ViewController.swift
//  GateOfBabylon
//
//  Created by Zhuojia on 2018/12/20.
//  Copyright © 2018 Alanli7991. All rights reserved.
//

import UIKit

class SGSampleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    let table = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
    let runes:[SGSampleRune] = [
        SGHitTestController.rune()
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ready For Singapore"
        
        view.backgroundColor = UIColor.white
        view.addSubview(table)
        
        let guide = view.safeAreaLayoutGuide
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                table.topAnchor.constraint(equalTo: guide.topAnchor),
                table.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
                table.leftAnchor.constraint(equalTo: guide.leftAnchor),
                table.rightAnchor.constraint(equalTo: guide.rightAnchor),
            ])
        table.dataSource = self
        table.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Controller")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Controller")
        }
        cell?.textLabel?.text = runes[indexPath.row].title
        cell?.detailTextLabel?.text = runes[indexPath.row].decription
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Gate Of Babylon"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rune = runes[indexPath.row]
        let vc = rune.clazz.init()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

