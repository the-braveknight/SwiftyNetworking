//
//  HTTPHeader.swift
//  
//
//  Created by Zaid Rahhawi on 8/13/22.
//

import Foundation

public protocol HTTPHeader {
    var field: String { get }
    var value: String { get }
}

public protocol HeaderKey {
    associatedtype Value: HeaderValue
    static var field: String { get }
    static var defaultValue: Self.Value { get }
}

public protocol HeaderValue {
    var value: String { get }
}

public struct HeaderValues {
    private init() {}
}

@propertyWrapper
public struct Header<Key: HeaderKey> : HTTPHeader {
    public let field: String
    public var wrappedValue: Key.Value
    
    public var value: String {
        wrappedValue.value
    }
    
    public init(wrappedValue: Key.Value, _ keyPath: KeyPath<HeaderValues, Key.Type>) {
        self.field = Key.field
        self.wrappedValue = wrappedValue
    }
    
    public init(_ keyPath: KeyPath<HeaderValues, Key.Type>) {
        self.field = Key.field
        self.wrappedValue = Key.defaultValue
    }
    
    public init(wrappedValue: Key.Value, key: Key.Type) {
        self.field = Key.field
        self.wrappedValue = wrappedValue
    }
    
    public init(key: Key.Type) {
        self.field = Key.field
        self.wrappedValue = Key.defaultValue
    }
}
