//
//  ConversationService.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 23. 2. 2023..
//

import Firebase

public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }

struct ConversationService {
    static let shared = ConversationService()
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let collectionMessage: [String : Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_uid": uid,
            "is_read": false,
            "name" : name
        ]
        
        let value: [String : Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        REF_CONVERSATIONS.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Creates a new conversation with the specified user and sent message
    public func createNewConversation(with otherUser: User, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = REF_USERS.child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String:Any] else {
                completion(false)
                print("DEBUG: User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let latestMessage: [String : Any] = [
                "date" : dateString,
                "message" : message,
                "is_read" : false
            ]
            
            let newConversationData: [String : Any] = [
                "id" : conversationId,
                "other_user_uid" : otherUser.uid,
                "name" : otherUser.name,
                "latest_message" : latestMessage
            ]
            
            let recipient_latestMessage: [String : Any] = [
                "date" : dateString,
                "message" : message,
                "is_read" : false
            ]
            
            UserService.shared.fetchUser(uid: uid) { user in
                let recipient_newConversationData: [String : Any] = [
                    "id" : conversationId,
                    "other_user_uid" : uid,
                    "name" : user.name,
                    "latest_message" : latestMessage
                ]
            }
            
            let recipient_newConversationData: [String : Any] = [
                "id" : conversationId,
                "other_user_uid" : uid,
                "name" : "Self",
                "latest_message" : latestMessage
            ]
            
//            Update recipient conversation entry
            ref.child("\(otherUser.uid)/conversations").observeSingleEvent(of: .value) { snapshot in
                if var conversations = snapshot.value as? [[String : Any]] {
//                    append
                    conversations.append(recipient_newConversationData)
                    ref.child("\(otherUser.uid)/conversations").setValue([recipient_newConversationData])
                }
                else {
//                    create
                    ref.child("\(otherUser.uid)/conversations").setValue([
                        recipient_newConversationData
                    ])
                }
            }
            
//            Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String : Any]] {
//                conversation array exists, you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishCreatingConversation(name: otherUser.name,
                                                    conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }
            }
            else {
//                conversation array doesn't exist, create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishCreatingConversation(name: otherUser.name,
                                                    conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }
            }
        }
    }
    
    /// Fetches and returns all conversations for passed in user
    public func getAllConversations(forUser user: User, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        REF_USERS.child("\(user.uid)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserUid = dictionary["other_user_uid"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String : Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else { return nil }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserUid: otherUserUid,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
            
        }
    }
    
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        REF_CONVERSATIONS.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap ({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderUid = dictionary["sender_uid"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString)
                else { return nil }
                
                let sender = Sender(photoURL: "", senderId: senderUid, displayName: name)
                
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
                        
            })
            
            completion(.success(messages))
            
        }
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversationId: String, otherUserUid: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
//        add new message to messages
//        update sender latest message
//        update recipient latest message
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_CONVERSATIONS.child("\(conversationId)/messages").observeSingleEvent(of: .value) { snapshot, _  in
            guard var currentMessages = snapshot.value as? [[String : Any]] else {
                completion(false)
                return
            }
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let newMessageEntry: [String : Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_uid": uid,
                "is_read": false,
                "name" : name
            ]
            
            currentMessages.append(newMessageEntry)
            
            REF_CONVERSATIONS.child("\(conversationId)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                REF_USERS.child("\(uid)/conversations").observeSingleEvent(of: .value) { snapshot, _  in
                    guard var currentUserConversations = snapshot.value as? [[String : Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String : Any] = [
                        "date" : dateString,
                        "message" : message,
                        "is_read" : false
                    ]
                    
                    var targetConversation: [String : Any]?
                    
                    var position = 0
                    
                    for conversation in currentUserConversations {
                        if let currentId = conversation["id"] as? String,
                           currentId == conversationId {
                            targetConversation = conversation
                            
                            break
                        }
                        position += 1
                        targetConversation?["latest_message"] = updatedValue
                        guard let finalConversation = targetConversation else {
                            completion(false)
                            return
                        }
                        currentUserConversations[position] = finalConversation
                        REF_USERS.child("\(conversationId)/conversations").setValue(currentUserConversations) { error, _ in
                            guard error == nil else {
                                 completion(false)
                                return
                            }
                            
                            completion(true)
                        }
                    }
                }
                
//                update other user latest message
                REF_USERS.child("\(otherUserUid)/conversations").observeSingleEvent(of: .value) { snapshot, _  in
                    guard var otherUserConversations = snapshot.value as? [[String : Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String : Any] = [
                        "date" : dateString,
                        "message" : message,
                        "is_read" : false
                    ]
                    
                    var targetConversation: [String : Any]?
                    
                    var position = 0
                    
                    for conversation in otherUserConversations {
                        if let currentId = conversation["id"] as? String,
                           currentId == conversationId {
                            targetConversation = conversation
                            
                            break
                        }
                        position += 1
                        targetConversation?["latest_message"] = updatedValue
                        guard let finalConversation = targetConversation else {
                            completion(false)
                            return
                        }
                        otherUserConversations[position] = finalConversation
                        REF_USERS.child("\(otherUserUid)/conversations").setValue(otherUserConversations) { error, _ in
                            guard error == nil else {
                                 completion(false)
                                return
                            }
                            
                            completion(true)
                        }
                    }
                }
            }
        }
    }
}
