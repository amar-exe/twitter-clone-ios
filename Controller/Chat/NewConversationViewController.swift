//
//  NewConversationViewController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 23. 2. 2023..
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [User]()
    private var results = [User]()
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .systemYellow
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.bounds.width/4, y: (view.bounds.height-200)/2, width: view.bounds.width / 2, height: 100)
    }
    
//    MARK: Selectors
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        
        spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
//        check if array has firebase results
        if hasFetched {
            //        if it does: filter
            filterUsers(with: query)
        }
        else {
            //        if not, fetch then filter
            UserService.shared.fetchUsers { [weak self] users in
                self?.hasFetched = true
                self?.users = users
                self?.filterUsers(with: query)
            }
        }

    }
    
    func filterUsers(with term: String) {
        //        update the UI
        guard hasFetched else { return }
        
        self.spinner.dismiss(animated: true)
        
        var results: [User] = self.users.filter({
            $0.username.contains(term)
        })
        
        self.results = results
        
        updateUI()
    }
    
    private func updateUI() {
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
