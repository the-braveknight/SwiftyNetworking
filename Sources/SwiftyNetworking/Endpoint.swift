//
//  Endpoint.swift
//  
//
//  Created by Zaid Rahhawi on 11/7/21.
//  Inspired by https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift/

import Foundation

// MARK: - Endpoint Protocol
/// Endpoint protocol
public protocol Endpoint {
    associatedtype Response
    
    var scheme: Scheme { get }
    var host: String { get }
    var port: Int? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [HTTPHeader] { get }
    func prepare(request: inout URLRequest)
    func parse(data: Data, urlResponse: URLResponse) throws -> Response
}

// - MARK: Additional Properties
public extension Endpoint {
    /// All queries marked with @Query property wrapper.
    var mirroredQueries: [URLQueryItem] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap { $0.value as? Query }.map(\.urlQueryItem)
    }
    
    /// All headers marked with @Header property wrapper.
    var mirroredHeaders: [HTTPHeader] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap { $0.value as? HTTPHeader }
    }
    
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        components.port = port
        components.queryItems = queryItems + mirroredQueries

        guard let url = components.url else {
            fatalError("Invalid URL components: \(components)")
        }

        return url
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = method.value
        
        switch method {
        case .post(let data), .put(let data), .patch(let data):
            request.httpBody = data
        default:
            break
        }
        
        headers.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        mirroredHeaders.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        prepare(request: &request)
        
        return request
    }
}

// MARK: - Default Implementation
public extension Endpoint {
    var scheme: Scheme { .https }
    var port: Int? { nil }
    var method : HTTPMethod { .get }
    var queryItems: [URLQueryItem] { [] }
    var headers: [HTTPHeader] { [] }
    func prepare(request: inout URLRequest) {}
}

public extension Endpoint where Response : Decodable {
    func parse(data: Data, urlResponse: URLResponse) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}

public extension Endpoint where Response == URLResponse {
    func parse(data: Data, urlResponse: URLResponse) throws -> Response {
        return urlResponse
    }
}
