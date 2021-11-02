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
    @StateObject var searchManager = SearchManager()
    
    var displayMode: NavigationBarItem.TitleDisplayMode {
        if #available(iOS 15, *) {
            return .automatic
        } else {
            return .inline
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if #available(iOS 15, *) {} else {
                    TextField("Search", text: $searchManager.searchText)
                        .modifier(ThemedTextFieldModifier())
                }
                
                ForEach(dataManager.filteredConversations) { conversation in
                    NavigationLink(destination: HistoryView(conversation: conversation)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.displayName(currentUserName: dataManager.loggedInUser))
                                .modifier(ThemedTextModifier(style: .title3))
                            Text(conversation.messageCountText)
                                .modifier(ThemedTextModifier(style: .caption))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle(Text("Conversations"), displayMode: displayMode)
            .navigationBarItems(leading: Button {
                dataManager.logout()
            } label: {
                Image(systemName: "arrow.left.circle")
                    .foregroundColor(colorScheme == .dark ? .lightTextColor : .darkTextColor)
            }
            )
            .onChange(of: searchManager.debouncedSearchText) { text in
                dataManager.filterConversations(searchText: text)
            }
            .modifier(NavSearchModifier(searchText: $searchManager.searchText))
            
            HistoryView()
        }
        .zIndex(2.0)
        .transition(.opacity)
        .onAppear {
            dataManager.getMessages(searchText: searchManager.debouncedSearchText)
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView()
    }
}
