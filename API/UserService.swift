//
//  UserService.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 29. 1. 2023..
//

import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

class UserService {
    
    static let shared = UserService()
    var isPaginating = false
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchCurrentUser(completion: @escaping(User) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            
            let user = User(uid: currentUid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void ) {
        var users = [User]()
        REF_USERS.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            let user = User(uid: uid, dictionary: dict)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { err, ref in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue { err, ref in
            REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let followers = snapshot.children.allObjects.count
            
            REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
    
    func updateProfileImage(image: UIImage, completion: @escaping(URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let filename = NSUUID().uuidString
        let ref = STORAGE_PROFILE_IMAGES.child(filename)
        
        ref.putData(imageData, metadata: nil) { meta, err in
            ref.downloadURL { url, err in
                guard let profileImageUrl = url?.absoluteString else { return }
                let values = ["profileImageUrl" : profileImageUrl]
                
                REF_USERS.child(uid).updateChildValues(values) { err, ref in
                    completion(url)
                }
            }
        }
    }
    
    func saveUserData(user: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["fullname" : user.name,
                      "username" : user.username,
                      "bio" : user.bio ?? ""]
        
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func fetchUser(withUsername username: String, completion: @escaping(User) -> Void) {
        REF_USER_USERNAMES.child(username).observeSingleEvent(of: .value) { snapshot in
            guard let uid = snapshot.value as? String else { return }
            self.fetchUser(uid: uid, completion: completion)
        }
    }
    
    func fetchUsers(startingAt startUser: User, pageSize: Int, completion: @escaping ([User]) -> Void) {
        var users = [User]()
        let query = REF_USERS.queryOrderedByKey().queryStarting(atValue: startUser.uid).queryLimited(toFirst: UInt(pageSize))
        query.observeSingleEvent(of: .value) { snapshot in
            guard var children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
//            print("MEGA DEBUG: Children count before uniqued(): \(children.count)")
            children = children.uniqued()
//            print("MEGA DEBUG: Children count after uniqued(): \(children.count)")
            for child in children {
                let uid = child.key
//                print("MEGA DEBUG: uid for each user: \(uid)")
                guard let dict = child.value as? [String: AnyObject] else { continue }
                if uid != startUser.uid {
                    let user = User(uid: uid, dictionary: dict)
                    users.append(user)
                }
            }
            users = users.uniqued()
            completion(users)
        }
    }
    
    func fetchUsers(pageSize: Int, completion: @escaping ([User]) -> Void) {
        var users = [User]()
        let query = REF_USERS.queryOrderedByKey().queryLimited(toFirst: UInt(pageSize))
//        query.observeSingleEvent(of: .value) { snapshot in
//            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
//                completion([])
//                return
//            }
//            for child in children {
//                let uid = child.key
//                guard let dict = child.value as? [String: AnyObject] else { continue }
//                let user = User(uid: uid, dictionary: dict)
//                users.append(user)
//            }
//            completion(users)
//        }
//
        isPaginating = true
        query.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion([])
                return
            }
            
            REF_USERS.observeSingleEvent(of: .value) { snapshot in
                let uid = snapshot.key
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                if uid != users.last?.uid {
                    let user = User(uid: uid, dictionary: dict)
                    users.append(user)
                }
                if users.count == snapshot.childrenCount {
                    // reached end of data
                    users = users.uniqued()
                    completion(users)
                    return
                }
                
                if users.count == pageSize {
                    users = users.uniqued()
                    completion(users)
                    return
                }
                print("ULTRA DEBUG: The completion being sent: \(users)")
                users = users.uniqued()
                completion(users)
                self.isPaginating = false
            }
            
//            snapshot.children.forEach { child in
//                guard let snapshot = child as? DataSnapshot else { return }
//                let uid = snapshot.key
//
//                self.fetchUser(uid: uid) { user in
//                    users.append(user)
//
//                    if users.count == snapshot.childrenCount {
//                        // reached end of data
//                        completion(users)
//                        return
//                    }
//
//                    if users.count == pageSize {
//                        completion(users)
//                        return
//                    }
//
//
//                }
//            }
        }
    }

    
}
