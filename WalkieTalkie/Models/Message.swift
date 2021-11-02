//
//  Message.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import Foundation

struct Message: Codable, Identifiable {
    static let path = "history"
    
    let id: Int
    let usernameFrom: String?
    let timestamp: String
    let recording: String
    let usernameTo: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case usernameFrom = "username_from"
        case timestamp
        case recording
        case usernameTo = "username_to"
    }
    
    var sortedId: String {
        [usernameTo ?? "", usernameFrom ?? ""].sorted().joined(separator: "_")
    }
    
    var date: Date {
        if let timeDouble = Double(timestamp) {
            return Date(timeIntervalSince1970: timeDouble)
        }
        return Date()
    }
}

final class GetMessagesRequest: APIRequest {
    var url: URL
    var method: HttpMethod = .get([])
    
    init() {
        url = APIClient.default.serverURL.appendingPathComponent(Message.path)
    }
}
