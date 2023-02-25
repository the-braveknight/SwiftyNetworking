//
//  Authorization.swift
//  
//
//  Created by Zaid Rahhawi on 2/25/23.
//

import Foundation

public enum Auth: HeaderKey {
    public static let field: String = "Authorization"
    public static let defaultValue: Authorization = .basic("None")
}

public enum Authorization : HeaderValue {
    case bearer(token: String)
    case basic(String)
    
    public var value: String {
        switch self {
        case .bearer(let token):
            return "Bearer \(token)"
        case .basic(let string):
            return "Basic \(string)"
        }
    }
}

public extension HeaderValues {
    var auth: Auth.Type {
        Auth.self
    }
}
