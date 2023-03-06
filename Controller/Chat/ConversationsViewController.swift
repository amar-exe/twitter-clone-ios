//
//  ConversationsController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
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
        startListeningForConversations()
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
    
    private func startListeningForConversations() {
        
        UserService.shared.fetchCurrentUser { user in
            ConversationService.shared.getAllConversations(forUser: user) { [weak self] result in
                switch result {
                case .success(let conversations):
                    guard !conversations.isEmpty else { return }
                    self?.conversations = conversations
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print("failed to fetch convos with error: \(error)")
                }
            }
        }
        
        
    }
    
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

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier, for: indexPath) as! ConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        UserService.shared.fetchUser(uid: model.otherUserUid) { [weak self] user in
            DispatchQueue.main.async {
                let vc = ChatViewController(withUser: user, id: model.id)
                vc.isNewConversation = false
                vc.title = model.name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
