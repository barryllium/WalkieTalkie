//
//  HistoryView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var conversation: Conversation?
    
    @ViewBuilder
    var body: some View {
        if #available(iOS 15, *) {
            List {
                ForEach(dataManager.filteredMessages) { message in
                    Text("\(message.usernameFrom ?? "Unknown User") to \(message.usernameTo ?? "Unknown User")")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
            }
                .modifier(HistoryModifier(conversation: conversation))
                .refreshable {
                    await dataManager.getAsyncMessages()
                }
        } else {
            RefreshableScrollView(height: 70,
                                  isRefreshing: $dataManager.isRefreshing,
                                  canRefresh: $dataManager.canRefresh) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(dataManager.filteredMessages) { message in
                        Text("\(message.usernameFrom ?? "Unknown User") to \(message.usernameTo ?? "Unknown User")")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    
                    Spacer()
                }
            }
                                  
        }
    }
    
    struct HistoryModifier: ViewModifier {
        @EnvironmentObject var dataManager: DataManager
        
        var conversation: Conversation?
        
        func body(content: Content) -> some View {
            content
                .navigationBarTitle(Text("Conversation"), displayMode: .automatic)
                .modifier(NavSearchModifier(searchText: $dataManager.messageSearchText))
                .onAppear {
                    dataManager.messageSearchText = ""
                    dataManager.setCurrentMessages(conversation: conversation)
                }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
