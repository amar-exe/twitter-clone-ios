//
//  AuthService.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 27. 1. 2023..
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct AuthCredentials {
    let email: String
    let password: String
    let name: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func registerUser(credentials: AuthCredentials) {
        let email = credentials.email
        let password = credentials.password
        let name = credentials.name
        let username = credentials.username
        let profileImage = credentials.profileImage
        
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            storageRef.downloadURL { url, error  in
                guard let profilePicUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    guard let uid = result?.user.uid else {
                        print("error u uid")
                        return }
                    
                    let values = ["email": email, "username": username, "name": name, "profilePicUrl": profilePicUrl]
                    
                    REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
                    }
                }
            }
        }
    }
}
