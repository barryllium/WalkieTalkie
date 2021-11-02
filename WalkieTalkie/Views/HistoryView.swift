//
//  HistoryView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject var searchManager = SearchManager()
    
    var conversation: Conversation?
    
    @ViewBuilder
    var body: some View {
        if #available(iOS 15, *) {
            List {
                ForEach(dataManager.filteredMessages) { message in
                    MessageView(message: message)
                }
            }
            .listStyle(.plain)
            .modifier(HistoryModifier(searchManager: searchManager, conversation: conversation))
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
                        ForEach(dataManager.filteredMessages) { message in
                            MessageView(message: message)
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
            .modifier(HistoryModifier(searchManager: searchManager, conversation: conversation))
        }
    }
    
    struct HistoryModifier: ViewModifier {
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var dataManager: DataManager
        @ObservedObject var searchManager: SearchManager
        
        var conversation: Conversation?
        
        var displayMode: NavigationBarItem.TitleDisplayMode {
            if #available(iOS 15, *) {
                return .automatic
            } else {
                return .inline
            }
        }
        
        func body(content: Content) -> some View {
            content
                .navigationBarTitle(Text("Conversation"), displayMode: displayMode)
                .modifier(NavSearchModifier(searchText: $searchManager.searchText))
                .navigationBarItems(trailing: trailingView)
                .onChange(of: searchManager.debouncedSearchText) { text in
                    dataManager.filterMessages(searchText: text)
                }
                .onAppear {
                    dataManager.setCurrentMessages(conversation: conversation, searchText: searchManager.searchText)
                }
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

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView().environmentObject(DataManager())
    }
}
