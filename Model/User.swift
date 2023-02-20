//
//  User.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 29. 1. 2023..
//

import Foundation
import Firebase

struct User: Equatable {
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    var name: String
    var username: String
    let email: String
    var profileImageUrl: URL?
    let uid: String
    var isFollowed = false
    var stats: UserRelationStats?
    var bio: String?
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(uid: String, dictionary: [String : AnyObject]) {
        self.uid = uid
        
        self.name = dictionary["name"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
        
        
    }
}

struct UserRelationStats {
    let followers: Int
    let following: Int
    
    
}
