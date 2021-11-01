//
//  User.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import Foundation

struct User: Codable {
    let name: String
    let role: Role
    
    enum Role: String, Codable {
        case admin = "ADMIN"
        case user = "USER"
    }
}
