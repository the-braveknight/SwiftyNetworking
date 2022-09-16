//
//  ArrayBuilder.swift
//
//
//  Created by Zaid Rahhawi on 11/7/21.
//

import Foundation

@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildExpression(_ element: Element) -> [Element] {
        return [element]
    }
    
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        return component ?? []
    }
    
    public static func buildEither(first component: [Element]) -> [Element] {
        return component
    }
    
    public static func buildEither(second component: [Element]) -> [Element] {
        return component
    }
    
    public static func buildArray(_ components: [[Element]]) -> [Element] {
        return Array(components.joined())
    }
    
    public static func buildBlock(_ components: [Element]...) -> [Element] {
        return Array(components.joined())
    }
}

public typealias QueriesBuilder = ArrayBuilder<URLQueryItem>
public typealias HeadersBuilder = ArrayBuilder<HTTPHeader>
