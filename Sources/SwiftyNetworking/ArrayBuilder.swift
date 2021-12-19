//
//  ArrayBuilder.swift
//
//
//  Created by Zaid Rahhawi on 11/7/21.
//

import Foundation

@resultBuilder
public struct ArrayBuilder {
    static func buildExpression<Item>(_ element: Item) -> [Item] {
        return [element]
    }
    
    static func buildOptional<Item>(_ component: [Item]?) -> [Item] {
        return component ?? []
    }
    
    static func buildEither<Item>(first component: [Item]) -> [Item] {
        return component
    }
    
    static func buildEither<Item>(second component: [Item]) -> [Item] {
        return component
    }
    
    static func buildArray<Item>(_ components: [[Item]]) -> [Item] {
        return Array(components.joined())
    }
    
    static func buildBlock<Item>(_ components: [Item]...) -> [Item] {
        return Array(components.joined())
    }
}
