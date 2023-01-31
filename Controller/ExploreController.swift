//
//  ExploreController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit

class ExploreController: UITableViewController {
    
    private var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        fetchUsers()
    }
    
//    MARK: API
    
    func fetchUsers() {
        UserService.shared.fetchUsers { users in
            self.users = users
        }
    }
    

//    helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Explore"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
    }

}

extension ExploreController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
}
