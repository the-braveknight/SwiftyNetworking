//
//  Endpoint.swift
//  
//
//  Created by Zaid Rahhawi on 11/7/21.
//  Inspired by https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift/

import Foundation
import Combine

// MARK: - Endpoint Protocol
/// Endpoint protocol
public protocol Endpoint {
    associatedtype Response
    
    var scheme: Scheme { get }
    var host: String { get }
    var path: String { get }
    var method: Method { get }
    var queryItems: [URLQueryItem] { get }
    func prepare(request: inout URLRequest)
    func parse(_ data: Data) throws -> Response
}

public enum Scheme : String {
    case http, https
}

public enum Method {
    case get
    case post(data: Data)
    case put(data: Data)
    case patch(data: Data)
    case delete
    
    var value: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        }
    }
}

// - MARK: Additional Properties
public extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            fatalError("Invalid URL components: \(components)")
        }

        return url
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        
        switch method {
        case .post(let data), .put(let data), .patch(let data):
            request.httpMethod = method.value
            request.httpBody = data
        default:
            request.httpMethod = method.value
        }
        
        prepare(request: &request)
        
        return request
    }
}

// MARK: - Default Implementation
public extension Endpoint {
    var scheme: Scheme { .https }
    var method : Method { .get }
    var queryItems: [URLQueryItem] { [] }
    func prepare(request: inout URLRequest) {}
}

public extension Endpoint where Response : Decodable {
    func prepare(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    func parse(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
