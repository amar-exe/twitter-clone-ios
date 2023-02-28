//
//  AuthService.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 27. 1. 2023..
//

import Foundation
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let name: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void ) {
        let email = credentials.email
        let password = credentials.password
        let name = credentials.name
        let username = credentials.username
        
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        STORAGE_PROFILE_IMAGES.child(filename).putData(imageData) { meta, error in
            storageRef.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("error is \(error.localizedDescription)")
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let values = ["email" : email, "username" : username, "name" : name, "profileImageUrl" : profileImageUrl]
                    
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                    
                }
            }
        }
    }
}
