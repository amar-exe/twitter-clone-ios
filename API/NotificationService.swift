//
//  NotificationService.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 3. 2. 2023..
//

import Firebase

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(type: NotificationType, tweet: Tweet? = nil ) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String : Any] = ["timestamp" : Int(NSDate().timeIntervalSince1970),
                                      "uid" : uid,
                                      "type" : type.rawValue]
        
        if let tweet = tweet {
            values["tweetID"] = tweet.tweetID
            REF_NOTIFICATIONS.child(tweet.user.uid).childByAutoId().updateChildValues(values)
        } else {
            
        }
    }
}
