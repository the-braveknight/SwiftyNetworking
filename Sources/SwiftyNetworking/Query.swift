//
//  Query.swift
//  
//
//  Created by Zaid Rahhawi on 2/25/23.
//

import Foundation

@propertyWrapper
public struct Query {
    public let name: String
    public var value: String?
    
    public var wrappedValue: String? {
        get { value }
        set { value = newValue }
    }
    
    public var urlQueryItem: URLQueryItem {
        URLQueryItem(name: name, value: value)
    }
    
    public init(wrappedValue: String? = nil, name: String) {
        self.name = name
        self.value = wrappedValue
    }
}
