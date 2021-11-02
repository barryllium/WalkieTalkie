//
//  DataManager.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import Foundation
import Combine
import SwiftUI
import AVKit

class DataManager: ObservableObject {
    @AppStorage("current_user") var loggedInUser: String?
    
    @Published var history: [Message] = []
    @Published var currentUser: User?
    @Published var conversations: [Conversation] = []
    @Published var filteredConversations: [Conversation] = []
    
    @Published var currentMessages: [Message] = []
    @Published var filteredMessages: [Message] = []
    @Published var playingMessage: Message?
    @Published var player = AVPlayer()
    
    // MARK: TextFields
    @Published var userName: String = ""
    
    // MARK: Pull-to-refresh
    @Published var canRefresh = true
    @Published var isRefreshing = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        currentUser = getCurrentUser()
    }
    
    func clearData() {
        userName = ""
        history = []
        filteredConversations = []
        filteredMessages = []
        playingMessage = nil
        player.pause()
    }
    
    // MARK: - User functions
    func login() {
        loggedInUser = userName
        currentUser = getCurrentUser()
    }
    
    func logout() {
        loggedInUser = nil
    }
    
    func getCurrentUser() -> User? {
        let admins = ["Brett", "kyle_ski"]
        if let loggedInUser = loggedInUser {
            return User(name: loggedInUser, role: admins.contains(loggedInUser.lowercased()) ? .admin : .user)
        }
        return nil
    }
    
    
    // MARK: - Conversation functions
    func createConversations(searchText: String) {
        conversations = []
        history.forEach { message in
            if let index = conversations.firstIndex(where: { $0.id == message.sortedId }) {
                conversations[index].addMessage(message: message)
            } else {
                conversations.append(Conversation(message: message))
            }
        }
        conversations.sort { $0.lastTimeStamp > $1.lastTimeStamp }
        filterConversations(searchText: searchText)
    }
    
    func filterConversations(searchText: String) {
        if searchText.isEmpty {
            filteredConversations = conversations
        } else {
            filteredConversations = conversations.filter { $0.id.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    
    // MARK: - Message functions
    func getMessages(searchText: String) {
        APIClient.default.fetchURL(GetMessagesRequest().urlRequest)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion,
                   let apiError = error as? APIError {
                    // TODO: Show Error
                    print(apiError)
                    self?.isRefreshing = false
                }
            } receiveValue: { [weak self] (messages: [Message]) in
                self?.processHistory(messages: messages, searchText: searchText)
                self?.isRefreshing = false
            }
            .store(in: &subscriptions)
    }
    
    @MainActor
    @available(iOS 15, *)
    func getAsyncMessages(searchText: String) async {
        Task { [weak self] in
            do {
                let request = AsyncURLRequest<[Message]>(apiRequest: GetMessagesRequest())
                let fullHistory = try await APIClient.default.fetchURLAsync(request)
                
                self?.processHistory(messages: fullHistory, searchText: searchText)
            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    
    private func processHistory(messages: [Message], searchText: String) {
        if self.currentUser?.role == .admin {
            self.history = messages
        } else {
            self.history = messages.filter {
                $0.usernameTo?.localizedCaseInsensitiveCompare(loggedInUser ?? "") == .orderedSame ||
                $0.usernameFrom?.localizedCaseInsensitiveCompare(loggedInUser ?? "") == .orderedSame
            }
        }
        self.createConversations(searchText: searchText)
    }
    
    func setCurrentMessages(conversation: Conversation?, searchText: String) {
        currentMessages = conversation?.messages ?? history
        filterMessages(searchText: searchText)
    }
    
    func filterMessages(searchText: String) {
        if searchText.isEmpty {
            filteredMessages = currentMessages
        } else {
            filteredMessages = currentMessages.filter {
                $0.usernameTo?.localizedCaseInsensitiveContains(searchText) ?? false ||
                $0.usernameFrom?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}
