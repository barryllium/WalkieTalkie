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
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(Int.self, forKey: .id)
//        usernameFrom = try? container.decode(String.self, forKey: .usernameFrom)
//        timestamp = try container.decode(String.self, forKey: .timestamp)
//        recording = try container.decode(String.self, forKey: .recording)
//        usernameTo = try? container.decode(String.self, forKey: .usernameTo)
//    }
    
    var sortedId: String {
        [usernameTo ?? "", usernameFrom ?? ""].sorted().joined(separator: "_")
    }
}

final class GetMessagesRequest: APIRequest {
    var url: URL
    var method: HttpMethod = .get([])
    
    init() {
        url = APIClient.default.serverURL.appendingPathComponent(Message.path)
    }
}
