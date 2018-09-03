//
//  AllUsersTableViewController.swift
//  Limbo
//
//  Created by A-Team User on 22.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class AllUsersTableViewController: UITableViewController {
    var users: [UserModel]?
    var selectedIndexes: [Int]!
    var groupChatDelegate: GroupChatDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emptyDataSetDelegate = CustomEmptyDataSetDelegate(emptyDataSetTitle: "No users around you to add.")
        self.tableView.emptyDataSetSource = emptyDataSetDelegate
        self.tableView.emptyDataSetDelegate = emptyDataSetDelegate
        
        let editable = groupChatDelegate != nil
        
        let barButtonItem = editable ?
            nil :
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(commitSelectedUsers))
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        tableView.allowsSelection = editable
        tableView.allowsMultipleSelection = editable
        
        self.selectedIndexes = editable ? Array() : nil
        self.tableView.reloadData()
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users != nil ? users!.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allUsersCell", for: indexPath)
        let user = users![indexPath.row]
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = user.username
        cell.tintColor = .white
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView? = backgroundView
        cell.imageView?.image = image(forAvatarString: user.avatarString)
        
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
        var selectedChatRoomUsers: [UserModel] = Array()
        for index in self.selectedIndexes {
            selectedChatRoomUsers.append(self.users![index])
        }
        self.groupChatDelegate?.createGroupChat(withUsers: selectedChatRoomUsers)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func dismissMe() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func image(forAvatarString avatarString: String) -> UIImage {
        if let defaultImage = UIImage(named: avatarString) {
            return defaultImage
        } else if let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: avatarString)!)) {
            return imgurImage
        } else {
            return #imageLiteral(resourceName: "ghost_avatar.png")
        }
    }

}
