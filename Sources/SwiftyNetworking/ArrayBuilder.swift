//
//  ArrayBuilder.swift
//  
//
//  Created by Zaid Rahhawi on 11/7/21.
//

import Foundation

@resultBuilder
public struct ArrayBuilder {
    public static func buildBlock<Item>(_ items: Item...) -> [Item] {
        return items
    }
}
