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
                Text("\(message.usernameFrom ?? "Unknown User") to \(message.usernameTo ?? "Unknown User")")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                Spacer()
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message(id: 1, usernameFrom: "From", timestamp: "123456789", recording: "", usernameTo: "")
        MessageView(message:message).environmentObject(DataManager())
    }
}
