//
//  ConversationView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List {
                if #available(iOS 15, *) {} else {
                    TextField("Search", text: $dataManager.conversationSearchText)
                        .modifier(ThemedTextFieldModifier())
                }
                
                ForEach(dataManager.filteredConversations) { conversation in
                    NavigationLink(destination: HistoryView()) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.displayName(currentUserName: dataManager.loggedInUser))
                                .modifier(ThemedTextModifier(style: .title3))
                            Text(conversation.messageCountText)
                                .modifier(ThemedTextModifier(style: .caption))
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Conversations"), displayMode: .automatic)
            .navigationBarItems(leading: Button {
                dataManager.logout()
            } label: {
                Image(systemName: "arrow.left.circle")
                    .foregroundColor(colorScheme == .dark ? .lightTextColor : .darkTextColor)
            }
            )
            .onChange(of: dataManager.conversationDebouncedSearchText) { _ in
                dataManager.filterConversations()
            }
            .modifier(NavSearchModifier(searchText: $dataManager.conversationSearchText))
            
            HistoryView()
        }
        .zIndex(2.0)
        .transition(.opacity)
        .onAppear {
            dataManager.getMessages()
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView()
    }
}
