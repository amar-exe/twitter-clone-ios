//
//  User.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 29. 1. 2023..
//

import Foundation
import Firebase

struct User {
    let name: String
    let username: String
    let email: String
    var profileImageUrl: URL?
    let uid: String
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(uid: String, dictionary: [String : AnyObject]) {
        self.uid = uid
        
        self.name = dictionary["name"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
            print("profile image url: \(profileImageUrlString)")
        }
        
        
    }
}
