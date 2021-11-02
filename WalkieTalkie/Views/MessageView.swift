//
//  MessageView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI
import AVKit

struct MessageView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var message: Message
    
    var body: some View {
        Button {
            if dataManager.player.timeControlStatus == .playing,
               dataManager.playingMessage?.id == message.id {
                dataManager.player.pause()
            } else {
                let recordingUrl = APIClient.default.serverURL.appendingPathComponent(message.recording)
                dataManager.player = AVPlayer(playerItem: AVPlayerItem(url: recordingUrl))
                dataManager.player.play()
                dataManager.playingMessage = message
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.messageName)
                        .modifier(ThemedTextModifier(style: .title3))
                    
                    Text(dataManager.dateFormatter.string(from: message.date))
                        .modifier(ThemedTextModifier(style: .caption, isSubText: true))
                }
                
                Spacer()
            }
        }
        .disabled(dataManager.isLoading)
        .accessibilityLabel(Text("Listen to message from \(message.messageName)"))
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message(id: 1, usernameFrom: "From", timestamp: "123456789", recording: "", usernameTo: "")
        MessageView(message:message).environmentObject(DataManager())
    }
}
