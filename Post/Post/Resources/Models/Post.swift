//
//  Post.swift
//  Post
//
//  Created by Josh Sparks on 9/30/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

struct Post: Codable {
    let text: String
    let timestamp: TimeInterval
    let username: String
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    var queryTimeStamp: TimeInterval {
        return self.timestamp - 0.00001
    }
}
