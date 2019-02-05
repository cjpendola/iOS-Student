//
//  Post.swift
//  Post
//
//  Created by Carlos Pendola on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

/*struct TopLevelDictionary: Codable{
    let posts:[Post]
}*/

struct Post: Codable{
    let username:  String
    let timestamp: TimeInterval
    let text:  String
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
}
