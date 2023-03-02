//
//  Conversation.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 24. 2. 2023..
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let otherUserUid: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
