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
    var queryItems: [URLQueryItem] { get }
    var headers: [String : String] { get }
    var method: Method { get }
    var contentType: ContentType { get }
    var accept: ContentType { get }
    func makeRequest() -> URLRequest?
    func parse(_ data: Data) throws -> Response
}

public enum Scheme : String {
    case http, https
}

public enum ContentType : String {
    case json = "application/json"
    case xml = "application/xml"
    case urlencoded = "application/x-www-form-urlencoded"
}

public enum Method {
    case get
    case post(data: Data)
    case put(data: Data)
    case patch
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

// MARK: - Default Implementation
public extension Endpoint {
    var scheme: Scheme { .https }
    var path: String { "/" }
    var method : Method { .get }
    var contentType : ContentType { .json }
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    
    func makeRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        // If either the path or the query items passed contained
        // invalid characters, we'll get a nil URL back:
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.value
        
        switch method {
        case .post(let data), .put(let data): request.httpBody = data
        default: break
        }
        
        request.setValue(accept.rawValue, forHTTPHeaderField: "Accept")
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

public extension Endpoint where Response : Decodable {
    var accept: ContentType { .json }
    
    func parse(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
