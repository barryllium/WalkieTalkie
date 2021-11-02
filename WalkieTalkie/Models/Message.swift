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
    
    // Creating an id that assures messages are grouped together regardless of who the sender is
    var sortedId: String {
        [usernameTo ?? "", usernameFrom ?? ""].sorted().joined(separator: "_")
    }
    
    // Generate a date from the timestamp, to be formatted for display
    var date: Date {
        if let timeDouble = Double(timestamp) {
            return Date(timeIntervalSince1970: timeDouble)
        }
        return Date()
    }
    
    // Friendly name for messages list UI
    var messageName: String {
        "\(usernameFrom ?? "Unknown User") to \(usernameTo ?? "Unknown User")"
    }
}

final class GetMessagesRequest: APIRequest {
    var url: URL
    var method: HttpMethod = .get([])
    
    init() {
        url = APIClient.default.serverURL.appendingPathComponent(Message.path)
    }
}
