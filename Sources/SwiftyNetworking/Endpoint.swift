//
//  Endpoint.swift
//  
//
//  Created by Zaid Rahhawi on 11/7/21.
//  Inspired by https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift/

import Foundation
import Combine

// MARK: - Protocol
/// Endpoint protocol
public protocol Endpoint {
    associatedtype Response
    
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var scheme: Scheme { get }
    func makeRequest() -> URLRequest?
    func parse(_ data: Data) throws -> Response
}

public enum Scheme : String {
    case http, https
}

// MARK: - Default Implementation
public extension Endpoint {
    var scheme: Scheme { .https }
    
    func makeRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = "/" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        // If either the path or the query items passed contained
        // invalid characters, we'll get a nil URL back:
        guard let url = components.url else {
            return nil
        }
        
        return URLRequest(url: url)
    }
}

public extension Endpoint where Response : Decodable {
    func parse(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
