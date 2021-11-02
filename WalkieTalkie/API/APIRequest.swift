//
//  APIRequest.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import Foundation

protocol APIRequest {
    var url: URL { get set }
    var method: HttpMethod { get set }
}

extension APIRequest {
    var urlRequest: URLRequest {
        var request = URLRequest(url: url)

        switch method {
        case .post(let data):
            request.httpBody = data
        case let .get(queryItems):
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            guard let url = components?.url else {
                preconditionFailure("Couldn't create a url from components...")
            }
            request = URLRequest(url: url)
        }

        request.httpMethod = method.name
        return request
    }
}

// Wrapping the APIRequest in a generic struct, so we can pass the decoding type as a phantom object
struct AsyncURLRequest<T> {
    var apiRequest: APIRequest
}

enum HttpMethod: Equatable {
    case get([URLQueryItem])
    case post(Data?)
    
    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}
