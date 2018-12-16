//
//  DataService.swift
//  Breakpoint
//
//  Created by Ketan Choyal on 14/12/18.
//  Copyright © 2018 Ketan Choyal. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    var feeds = [Feed]()
    
    public private(set) var REF_BASE = DB_BASE
    public private(set) var REF_USERS = DB_BASE.child("users")
    public private(set) var REF_GROUPS = DB_BASE.child("groups")
    public private(set) var REF_FEED = DB_BASE.child("feeds")
    
    func createDBUser(uid : String, userData : Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func getUsername(forUid uid : String, usernameHandler : @escaping (_ username : String) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (usernameSnapshot) in
            guard let usernameSnapshot = usernameSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in usernameSnapshot {
                if user.key == uid {
                    usernameHandler((user.childSnapshot(forPath: "email").value as? String)!)
                }
            }
        }
    }
    
    func uploadPost(withMessage message : String, forUid uid : String, withGroupKey groupKey : String?, sendComplete : @escaping (_ status : Bool) -> ()) {
        if groupKey != nil {
            // send to group ref
        } else {
            REF_FEED.childByAutoId().updateChildValues(["content" : message, "senderId" : uid])
            sendComplete(true)
        }
    }
    
    //TODO : Remove closures in the end
    
    func getAllFeedMessages(feedHandler : @escaping (_ complete : Bool) -> ()) {
        feeds.removeAll()
        REF_FEED.observeSingleEvent(of: .value) { (feedSnapshot) in
            guard let feeds = feedSnapshot.children.allObjects as? [DataSnapshot] else {
                feedHandler(false)
                return }
            
            for feed in feeds {
                let content = feed.childSnapshot(forPath: "content").value as? String
                let senderId = feed.childSnapshot(forPath: "senderId").value as? String
                
                let newfeed = Feed.init(senderID: senderId!, content: content!)
                
                self.feeds.append(newfeed)
            }
            feedHandler(true)
        }
    }
    
}
