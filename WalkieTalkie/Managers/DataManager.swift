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
    @AppStorage("current_user") var currentUser: String?
    
    @Published var userName: String = ""
    @Published var history: [Message] = []
    @Published var conversationSearchText = ""
    @Published var conversationDebouncedSearchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
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
    var userRole: User.Role {
        return .user
    }
    
    func login() {
        currentUser = userName
    }
    
    func logout() {
        currentUser = nil
    }
    
    
    // MARK: - Conversation functions
    func filterConversations() {
        
    }
    
    
    // MARK: - Message functions
    func getMessages() {
        APIClient.default.fetchURL(GetMessagesRequest().urlRequest)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion,
                   let apiError = error as? APIError {
                    print(apiError)
                }
            } receiveValue: { [weak self] (messages: [Message]) in
                if self?.userRole == .admin {
                    self?.history = messages
                } else {
                    self?.history = messages.filter {
                        $0.usernameTo?.localizedCaseInsensitiveCompare(self?.currentUser ?? "") == .orderedSame || $0.usernameFrom?.localizedCaseInsensitiveCompare(self?.currentUser ?? "") == .orderedSame
                    }
                }
                self?.filterMessages()
            }
            .store(in: &subscriptions)
    }
    
    func filterMessages() {
        
    }
}
