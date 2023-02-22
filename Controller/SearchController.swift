//
//  ExploreController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit

enum SearchControllerConfiguration {
    case messages
    case userSearch
}
 
class SearchController: UITableViewController {
    
    //    MARK: Properties
    
    private let config: SearchControllerConfiguration
    private var backgroundView: UIView!
    
    private var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var filteredUsers = [User]() {
        didSet {
            tableView.reloadData()
            backgroundView.isHidden = !filteredUsers.isEmpty
        }
    }
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    //    MARK: Lifecycle
    
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchUsers()
        configureSearchController()
        configureTableBackgroundView()
        configureRefreshControl()
        
        tableView.backgroundView = backgroundView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    //    MARK: API
    
    func fetchUsers() {
        UserService.shared.fetchUsers { users in
            self.users = users
        }
    }
    
//    MARK: Selectors
    
    @objc func handleRefresh() {
        fetchUsers()
        tableView.refreshControl?.endRefreshing()
    }
    
    @objc func handleDismissal() {
        dismiss(animated: true)
    }
    
    
//    MARK: Helpers
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func configureTableBackgroundView() {
        backgroundView = UIView(frame: tableView.bounds)
        backgroundView.backgroundColor = .white // set the background color
        let messageLabel = UILabel()
        messageLabel.text = "No users found" // set the message to display
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
        ])
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = config == .messages ? "New Message" : "Explore"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }

}

extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let vc = ProfileController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        filteredUsers = users.filter({ $0.username.contains(searchText) })
        
    }
}
