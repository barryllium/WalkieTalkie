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
    
    var history: [Message] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    func getMessages() {
        APIClient.default.fetchURL(GetMessagesRequest().urlRequest)
            .sink { completion in
                if case .failure(let error) = completion,
                   let apiError = error as? APIError {
                    print(apiError)
                }
            } receiveValue: { [weak self] (messages: [Message]) in
                self?.history = messages
            }
            .store(in: &subscriptions)
    }
}
