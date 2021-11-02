//
//  WalkieTalkieTests.swift
//  WalkieTalkieTests
//
//  Created by Brett Keck on 11/2/21.
//

import XCTest
import Nimble
import Combine
@testable import WalkieTalkie

class WalkieTalkieTests: XCTestCase {
    func testRequest() {
        let request = GetMessagesRequest().urlRequest
        
        let cancellable = APIClient.default.fetchURL(request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(_) = completion {
                    XCTFail()
                }
            } receiveValue: { (messages: [Message]) in
                expect(messages).to(haveCount(1000))

                let filteredMessages = messages.filter {
                    $0.usernameTo?.localizedCaseInsensitiveCompare("kyle_ski") == .orderedSame ||
                    $0.usernameFrom?.localizedCaseInsensitiveCompare("kyle_ski") == .orderedSame
                }
                expect(filteredMessages).to(haveCount(515))
            }
        
        expect(cancellable).toNot(beNil())
    }
    
    @MainActor
    func testAsyncRequest() async {
        do {
            let request = AsyncURLRequest<[Message]>(apiRequest: GetMessagesRequest())
            let messages = try await APIClient.default.fetchURLAsync(request)
            
            expect(messages).to(haveCount(1000))
            let filteredMessages = messages.filter {
                $0.usernameTo?.localizedCaseInsensitiveCompare("kyle_ski") == .orderedSame ||
                $0.usernameFrom?.localizedCaseInsensitiveCompare("kyle_ski") == .orderedSame
            }
            expect(filteredMessages).to(haveCount(515))
        } catch {
            XCTFail()
        }
    }
}
