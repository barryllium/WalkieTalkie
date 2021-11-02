//
//  MessageView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var message: Message
    
    var body: some View {
        HStack {
            Text("\(message.usernameFrom ?? "Unknown User") to \(message.usernameTo ?? "Unknown User")")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            Spacer()
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message(id: 1, usernameFrom: "From", timestamp: "123456789", recording: "", usernameTo: "")
        MessageView(message:message).environmentObject(DataManager())
    }
}
