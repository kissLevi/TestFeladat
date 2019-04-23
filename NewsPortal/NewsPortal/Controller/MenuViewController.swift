//
//  MenuViewController.swift
//  NewsPortal
//
//  Created by Kiss Levente on 2019. 04. 21..
//  Copyright © 2019. Kiss Levente. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    struct Storyboard{
        static let cellIdentifier = "SimpleCell"
    }
    
    var menuDelegate:MenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuDelegate?.menuItems().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdentifier, for: indexPath)
        cell.textLabel?.text = menuDelegate?.menuItems()[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menuDelegate = menuDelegate{
            menuDelegate.selectMenuItem(withName:menuDelegate.menuItems()[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
    }
}
