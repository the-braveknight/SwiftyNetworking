//
//  File.swift
//  
//
//  Created by Zaid Rahhawi on 12/18/21.
//

import Foundation

public extension URLSession {
    public func load<E: Endpoint>(_ endpoint: E, completionHandler: @escaping (Result<E.Response, Error>) -> Void) {
        guard let request = endpoint.makeRequest() else {
            completionHandler(.failure(URLError(.badURL)))
            return
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try endpoint.parse(data)
                    completionHandler(.success(response))
                } catch {
                    completionHandler(.failure(error))
                }
            } else if let error = error {
                completionHandler(.failure(error))
            }
        }
        
        task.resume()
    }
}


@available(iOS 13, macOS 10.15, *)
public extension URLSession {
    public func load<E : Endpoint>(_ endpoint: E) -> AnyPublisher<E.Response, Error> {
        guard let request = endpoint.makeRequest() else {
            return Fail<E.Response, Error>(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap(endpoint.parse)
            .eraseToAnyPublisher()
    }
    
    public func load<E : Endpoint>(_ endpoint: E) async throws -> E.Response {
        guard let request = endpoint.makeRequest() else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await data(for: request)
        let response = try endpoint.parse(data)
        return response
    }
}
