//
//  DataManager.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import Foundation
import Combine
import SwiftUI

class DataManager: ObservableObject {
    @AppStorage("current_user") var loggedInUser: String?
    
    @Published var history: [Message] = []
    @Published var currentUser: User?
    @Published var conversations: [Conversation] = []
    @Published var filteredConversations: [Conversation] = []
    
    @Published var currentMessages: [Message] = []
    @Published var filteredMessages: [Message] = []
    
    // MARK: TextFields
    @Published var userName: String = ""
    @Published var conversationSearchText = ""
    @Published var conversationDebouncedSearchText = ""
    
    @Published var messageSearchText = ""
    @Published var messageDebouncedSearchText = ""
    
    // MARK: Pull-to-refresh
    @Published var canRefresh = true
    @Published var isRefreshing = false {
        didSet {
            if !oldValue, isRefreshing, canRefresh {
                getMessages()
            }
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        currentUser = getCurrentUser()
        $conversationSearchText
            .debounce(for: .seconds(0.2),
                         scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.conversationDebouncedSearchText = $0
            }
            .store(in: &subscriptions)
    }
    
    func clearData() {
        userName = ""
        conversationSearchText = ""
        conversationDebouncedSearchText = ""
        history = []
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
    func createConversations() {
        conversations = []
        history.forEach { message in
            if let index = conversations.firstIndex(where: { $0.id == message.sortedId }) {
                conversations[index].addMessage(message: message)
            } else {
                conversations.append(Conversation(message: message))
            }
        }
        conversations.sort { $0.lastTimeStamp > $1.lastTimeStamp }
        filterConversations()
    }
    
    func filterConversations() {
        if conversationDebouncedSearchText.isEmpty {
            filteredConversations = conversations
        } else {
            filteredConversations = conversations.filter { $0.id.localizedCaseInsensitiveContains(conversationDebouncedSearchText)}
        }
    }
    
    
    // MARK: - Message functions
    func getMessages() {
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
                self?.processHistory(messages: messages)
                self?.isRefreshing = false
            }
            .store(in: &subscriptions)
    }
    
    @MainActor
    @available(iOS 15, *)
    func getAsyncMessages() async {
        Task { [weak self] in
            do {
                let request = AsyncURLRequest<[Message]>(apiRequest: GetMessagesRequest())
                let fullHistory = try await APIClient.default.fetchURLAsync(request)
                
                self?.processHistory(messages: fullHistory)
            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    
    private func processHistory(messages: [Message]) {
        if self.currentUser?.role == .admin {
            self.history = messages
        } else {
            self.history = messages.filter {
                $0.usernameTo?.localizedCaseInsensitiveCompare(loggedInUser ?? "") == .orderedSame ||
                $0.usernameFrom?.localizedCaseInsensitiveCompare(loggedInUser ?? "") == .orderedSame
            }
        }
        self.createConversations()
    }
    
    func setCurrentMessages(conversation: Conversation?) {
        currentMessages = conversation?.messages ?? history
        filterMessages()
    }
    
    func filterMessages() {
        if messageDebouncedSearchText.isEmpty {
            filteredMessages = currentMessages
        } else {
            filteredMessages = currentMessages.filter {
                $0.usernameTo?.localizedCaseInsensitiveContains(messageDebouncedSearchText) ?? false ||
                $0.usernameFrom?.localizedCaseInsensitiveContains(messageDebouncedSearchText) ?? false
            }
        }
    }
}
