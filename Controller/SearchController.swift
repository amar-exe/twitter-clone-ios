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
    
    let pageSize = 3
    
    public var completion: (([String : String]) -> Void)?
    
    private let config: SearchControllerConfiguration
    private var backgroundView: UIView!
    
    private var users = [User]() {
        didSet {
            backgroundView.isHidden = !users.isEmpty
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
        fetchCurrentUser()
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
    
    func fetchCurrentUser() {
        UserService.shared.fetchCurrentUser { [weak self] user in
            self?.users.append(user)
            self?.tableView.reloadData()
            self?.tableView.tableFooterView = nil
        }
    }
    
    func fetchUsers() {
        guard let lastUser = self.users.last else {
            return
        }
        UserService.shared.fetchUsers(startingAt: lastUser, pageSize: pageSize) { [weak self] users in
//            if lastUser.uid != users.first?.uid {
                self?.tableView.tableFooterView = self?.createSpinnerFooter()
                self?.users.append(contentsOf: users)
                let noDuplicates = self?.users.uniqued()
//                if noDuplicates?.count != self?.users.count {
                    self?.users = noDuplicates ?? users
                    self?.tableView.tableFooterView = nil
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
//                }
//            }
        }
//        UserService.shared.fetchUsers { users in
//            self.users = users
//        }
    }
    
    func checkForDuplicates() {
        users = users.uniqued()
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
        tableView.register(SelfUserCell.self, forCellReuseIdentifier: SelfUserCell.reuseIdentifier)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SelfUserCell.reuseIdentifier, for: indexPath) as! SelfUserCell
            cell.user = users[0]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 && config == .messages {
            return
        }
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let vc = config == .messages ? createNewConversation(withUser: user) : ProfileController(user: user)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func createNewConversation(withUser user: User) -> ChatViewController {
        let vc = ChatViewController(withUser: user, id: nil)
        vc.isNewConversation = true
        vc.title = user.name
        vc.navigationItem.largeTitleDisplayMode = .never
        return vc
    }
}

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased().replacingOccurrences(of: " ", with: "") else { return }
        
        filteredUsers = users.filter({ $0.username.contains(searchText) })
        
    }
}

extension SearchController {
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y

        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            guard !UserService.shared.isPaginating else { return }
            fetchUsers()
            self.tableView.tableFooterView = nil
        }
    }
}
