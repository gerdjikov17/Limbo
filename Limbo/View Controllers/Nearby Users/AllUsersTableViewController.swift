//
//  AllUsersTableViewController.swift
//  Limbo
//
//  Created by A-Team User on 22.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class AllUsersTableViewController: UITableViewController {
    var users: [UserModel]?
    var selectedIndexes: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(commitSelectedUsers))
        tableView.allowsMultipleSelection = true
        self.selectedIndexes = Array()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard users != nil else {
            return 0
        }
        return users!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allUsersCell", for: indexPath)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = users![indexPath.row].username
        cell.tintColor = .white
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView? = backgroundView
        if let defaultImage = UIImage(named: users![indexPath.row].avatarString) {
            cell.imageView?.image = defaultImage
        }
        else {
            if let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: users![indexPath.row].avatarString)!)) {
                cell.imageView?.image = imgurImage
            }
            else {
                cell.imageView?.image = #imageLiteral(resourceName: "ghost_avatar.png")
            }
            
        }
        if self.selectedIndexes.contains(indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndexes.contains(indexPath.row) {
            self.selectedIndexes.remove(at: self.selectedIndexes.index(of: indexPath.row)!)
        }
        else {
            self.selectedIndexes.append(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc func commitSelectedUsers() {
        guard self.selectedIndexes.count >= 2 else {
            self.view.window?.makeToast("Selected users must be at least 2")
            return
        }
        
        
    }

}
