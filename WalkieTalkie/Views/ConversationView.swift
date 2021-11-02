//
//  ConversationView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/2/21.
//

import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var conversation: Conversation
    
    var body: some View {
        NavigationLink(destination: HistoryView(conversation: conversation)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.displayName(currentUserName: dataManager.loggedInUser))
                        .modifier(ThemedTextModifier(style: .title3))
                    Text(conversation.messageCountText)
                        .modifier(ThemedTextModifier(style: .caption))
                }
                Spacer()
            }
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message(id: 1, usernameFrom: "From", timestamp: "123456789", recording: "", usernameTo: "")
        ConversationView(conversation: Conversation(message: message)).environmentObject(DataManager())
    }
}
