//
//  File.swift
//
//
//  Created by Zaid Rahhawi on 12/18/21.
//

import Foundation

public extension URLSession {
    @discardableResult
    func load<E: Endpoint>(_ endpoint: E, completionHandler: @escaping (Result<E.Response, Error>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: endpoint.request) { data, response, error in
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
        
        return task
    }
}

#if canImport(Combine)
import Combine

@available(iOS 13, macOS 10.15, *)
public extension URLSession {
    func load<E : Endpoint>(_ endpoint: E) -> AnyPublisher<E.Response, Error> {
        return dataTaskPublisher(for: endpoint.request)
            .map(\.data)
            .tryMap(endpoint.parse)
            .eraseToAnyPublisher()
    }
}
#endif

#if swift(>=5.5)
@available(iOS 15, macOS 12, *)
public extension URLSession {
    func load<E : Endpoint>(_ endpoint: E) async throws -> E.Response {
        let (data, _) = try await data(for: endpoint.request)
        let response = try endpoint.parse(data)
        return response
    }
}
#endif
