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
    
    // MARK: TextFields
    @Published var userName: String = ""
    @Published var conversationSearchText = ""
    @Published var conversationDebouncedSearchText = ""
    
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
            .sink { completion in
                if case .failure(let error) = completion,
                   let apiError = error as? APIError {
                    // TODO: Show Error
                    print(apiError)
                }
            } receiveValue: { [weak self] (messages: [Message]) in
                if self?.currentUser?.role == .admin {
                    self?.history = messages
                } else {
                    self?.history = messages.filter {
                        return $0.usernameTo?.localizedCaseInsensitiveCompare(self?.loggedInUser ?? "") == .orderedSame || $0.usernameFrom?.localizedCaseInsensitiveCompare(self?.loggedInUser ?? "") == .orderedSame
                    }
                }
                self?.createConversations()
            }
            .store(in: &subscriptions)
    }
}
