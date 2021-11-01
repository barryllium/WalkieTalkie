//
//  APIClient.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import Foundation
import Combine

class APIClient {
    let serverURL: URL
    
    static let `default` = APIClient()
    
    init() {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SERVER_URL") as? String,
              let url = URL(string: urlString) else {
                  fatalError("No server url found in plist")
              }
        self.serverURL = url
    }
    
    func fetchURL<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                let decoder = JSONDecoder()
                guard let urlResponse = result.response as? HTTPURLResponse, (200...299).contains(urlResponse.statusCode) else {
                    let apiError = try decoder.decode(APIError.self, from: result.data)
                    throw apiError
                }
                
                return try decoder.decode(T.self, from: result.data)
            }
            .tryCatch { error -> AnyPublisher<T, Error> in
                throw error
            }
            .eraseToAnyPublisher()
    }
}

struct APIError: Decodable, Error {
    let statusCode: Int
}
