//
//  Conversation.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/2/21.
//

import Foundation

struct Conversation: Identifiable {
    var id: String
    var messages: [Message]
    
    var lastTimeStamp: Int {
        Int(messages.first?.timestamp ?? "0") ?? 0
    }
    
    var messageCountText: String {
        // Ideally this would use a Localized Strings dict
        "\(messages.count) Message\(messages.count == 1 ? "" : "s")"
    }
    
    init(message: Message) {
        id = message.sortedId
        messages = [message]
    }
    
    func displayName(currentUserName: String?) -> String {
        if let currentUserName = currentUserName {
            if messages.first?.usernameTo == currentUserName {
                return messages.first?.usernameFrom ?? "Unknown User"
            } else if messages.first?.usernameFrom == currentUserName {
                return messages.first?.usernameTo ?? "Unknown User"
            }
        }
        return "\(messages.first?.usernameFrom ?? "Unknown User") and \(messages.first?.usernameTo ?? "Unknown User")"
    }
    
    mutating func addMessage(message: Message) {
        messages.append(message)
        messages.sort { $0.timestamp > $1.timestamp }
    }
}
