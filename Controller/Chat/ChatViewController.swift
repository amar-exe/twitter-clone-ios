//
//  ChatViewController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 23. 2. 2023..
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseAuth

struct Message: MessageType {
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var conversations = [Conversation]()
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUser: User
    public var isNewConversation = false
    private var conversationId: String?
    
    private var messages = [Message]()
    
    
    private var selfSender: Sender? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        return Sender(photoURL: "",
                      senderId: currentUid,
                      displayName: "Me")
    }
    
//    MARK: Lifecycle

    init(withUser user: User, id: String?) {
        self.otherUser = user
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow
        }) else { return }
        
        guard let tab = window.rootViewController as? MainTabController else { return }
//        tab.actionButton.isHidden = true
        setViewIsHidden(view: tab.actionButton, hidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow
        }) else { return }
        
        guard let tab = window.rootViewController as? MainTabController else { return }
//        tab.actionButton.isHidden = false
        setViewIsHidden(view: tab.actionButton, hidden: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
//    MARK: Helpers
    
    func setViewIsHidden(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        ConversationService.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                    
                }
            case .failure(let error):
                print("failed to get messages due to: \(error)")
            }
            
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else { return }
        
        print("DEBUG: Sending message: \(text)")
        
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
//        Send message
        if isNewConversation {
//            create convo in database
            
            ConversationService.shared.createNewConversation(with: otherUser, firstMessage: message) { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                } else {
                    print("failed to send")
                }
            }
        }
        else {
            guard let conversationId = conversationId, let name = self.title else { return }
            //        append to existing conversation
            ConversationService.shared.sendMessage(to: conversationId, otherUserUid: otherUser.uid, name: name, newMessage: message) { success in
                if success {
                    print("message appended")
                }
                else {
                    print("message not appended")
                }
            }
        }

    }
    
    private func createMessageId() -> String? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        let dateString = Self.dateFormatter.string(from: Date())
        var newIdentifier = "\(otherUser.uid)_\(currentUid)_\(dateString)"
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("selfSender is nil, email should have been cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
