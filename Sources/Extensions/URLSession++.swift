//
//  File.swift
//
//
//  Created by Zaid Rahhawi on 12/18/21.
//

import Foundation

public extension URLSession {
    @discardableResult
    internal func load<E : Endpoint>(_ endopoint: E, completionHandler: @escaping (Result<(Data, URLResponse), Error>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: endopoint.request) { data, response, error in
            if let data = data, let response = response {
                completionHandler(.success((data, response)))
            } else if let error = error {
                completionHandler(.failure(error))
            }
        }
        
        task.resume()
        
        return task
    }
    
    @discardableResult
    func load<E: Endpoint>(_ endpoint: E, completionHandler: @escaping (Result<E.Response, Error>) -> Void) -> URLSessionDataTask {
        return load(endpoint) { result in
            do {
                let (data, urlResponse) = try result.get()
                let response = try endpoint.parse(data: data, urlResponse: urlResponse)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}

#if canImport(Combine)
import Combine

@available(iOS 13, macOS 10.15, *)
public extension URLSession {
    internal func load<E : Endpoint>(_ endpoint: E) -> DataTaskPublisher {
        return dataTaskPublisher(for: endpoint.request)
    }
    
    func load<E : Endpoint>(_ endpoint: E) -> AnyPublisher<E.Response, Error> {
        return dataTaskPublisher(for: endpoint.request)
            .tryMap(endpoint.parse)
            .eraseToAnyPublisher()
    }
}
#endif

#if swift(>=5.5)
@available(iOS 15, macOS 12, *)
public extension URLSession {
    internal func load<E : Endpoint>(_ endpoint: E) async throws -> (Data, URLResponse) {
        return try await data(for: endpoint.request)
    }
    
    func load<E : Endpoint>(_ endpoint: E) async throws -> E.Response {
        let (data, urlResponse) = try await load(endpoint)
        let response = try endpoint.parse(data: data, urlResponse: urlResponse)
        return response
    }
}
#endif
