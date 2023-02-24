//
//  ConversationsController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit
import JGProgressHUD

class ConversationsController: UIViewController {
    
    
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations! Try messaging someone"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))

        configureUI()
        configureTableView()
        configureNoConversationsLabel()
        fetchConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
//    MARK: Selectors
    
    @objc func didTapComposeButton() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow
        }) else { return }
        
        guard let tab = window.rootViewController as? MainTabController else { return }
        tab.actionButtonTapped()
    }
    

//    MARK: Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Messages"
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureNoConversationsLabel() {
        view.addSubview(noConversationsLabel)
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
}

extension ConversationsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController(withUser: User(uid: "", dictionary: [:]))
        vc.title = "Random Name"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
