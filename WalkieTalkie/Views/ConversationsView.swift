//
//  ConversationsView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct ConversationsView: View {
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
            if #available(iOS 15, *) {
                List {
                    allMessagesView
                    
                    ForEach(dataManager.filteredConversations) { conversation in
                        ConversationView(conversation: conversation)
                    }
                }
                .listStyle(.plain)
                .modifier(ConversationsModifier(searchManager: searchManager))
                .refreshable {
                    await dataManager.getAsyncMessages(searchText: searchManager.debouncedSearchText)
                }
            } else {
                VStack {
                    if searchManager.isShowingSearch {
                        TextField("Search", text: $searchManager.searchText)
                            .modifier(ThemedTextFieldModifier())
                    }
                    
                    RefreshableScrollView(height: 70,
                                          isRefreshing: $dataManager.isRefreshing,
                                          canRefresh: $dataManager.canRefresh,
                                          startRefresh: {
                        if !dataManager.isRefreshing, dataManager.canRefresh {
                            dataManager.isRefreshing = true
                            dataManager.getMessages(searchText: searchManager.debouncedSearchText)
                        }
                        
                    }) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            allMessagesView
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            ForEach(dataManager.filteredConversations) { conversation in
                                ConversationView(conversation: conversation)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .modifier(ConversationsModifier(searchManager: searchManager))
            }
            
            
            HistoryView()
        }
        .zIndex(2.0)
        .transition(.opacity)
        .onAppear {
            dataManager.getMessages(searchText: searchManager.debouncedSearchText)
        }
    }
    
    var allMessagesView: some View {
        NavigationLink(destination: HistoryView()) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("All Messages")
                        .modifier(ThemedTextModifier(style: .title3))
                    Text("\(dataManager.history.count) Message\(dataManager.history.count == 1 ? "" : "s")")
                        .modifier(ThemedTextModifier(style: .caption))
                }
                Spacer()
            }
        }
    }
    
    struct ConversationsModifier: ViewModifier {
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var dataManager: DataManager
        @ObservedObject var searchManager: SearchManager
        
        var displayMode: NavigationBarItem.TitleDisplayMode {
            if #available(iOS 15, *) {
                return .automatic
            } else {
                return .inline
            }
        }
        
        func body(content: Content) -> some View {
            content
                .navigationBarTitle(Text("Conversations"), displayMode: displayMode)
                .navigationBarItems(leading: Button {
                    dataManager.logout()
                } label: {
                    Image(systemName: "arrow.left.circle")
                        .foregroundColor(colorScheme == .dark ? .lightTextColor : .darkTextColor)
                }, trailing: trailingView)
                .onChange(of: searchManager.debouncedSearchText) { text in
                    dataManager.filterConversations(searchText: text)
                }
                .modifier(NavSearchModifier(searchText: $searchManager.searchText))
        }
        
        @ViewBuilder
        var trailingView: some View {
            if #available(iOS 15, *) {
                EmptyView()
            } else {
                Button {
                    withAnimation {
                        searchManager.isShowingSearch.toggle()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(colorScheme == .dark ? .lightTextColor : .darkTextColor)
                }
            }
        }
    }
}

struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView().environmentObject(DataManager())
    }
}
