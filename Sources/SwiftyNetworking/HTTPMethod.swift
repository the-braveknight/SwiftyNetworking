//
//  HTTPMethod.swift
//  
//
//  Created by Zaid Rahhawi on 8/13/22.
//

import Foundation

public enum HTTPMethod {
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
