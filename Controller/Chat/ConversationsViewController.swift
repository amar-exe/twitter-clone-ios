//
//  ConversationsController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit
import JGProgressHUD
import SnapKit

class ConversationsViewController: UIViewController {
    
    private var backgroundView: UIView!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    public var conversations = [Conversation]() {
        didSet {
            backgroundView.isHidden = !conversations.isEmpty
        }
    }
    
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
        tableView.backgroundView = backgroundView
        fetchConversations()
        startListeningForConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.center = view.center
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
        backgroundView = UIView(frame: tableView.bounds)
        backgroundView.backgroundColor = .white // set the background color
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sad-bird")
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 2
        messageLabel.text = "No messages yet. Try sending one!" // set the message to display
        messageLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        messageLabel.textColor = .lightGray
        messageLabel.textAlignment = .center
        backgroundView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.safeAreaLayoutGuide.snp.top).offset(200)
            make.leading.equalToSuperview().offset(96)
            make.trailing.equalToSuperview().offset(-96)
//            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-300)
        }
        backgroundView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
//            make.bottom.equalToSuperview()
        }
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
