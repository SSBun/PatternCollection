//
//  ConsistentHashValue.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/6.
//

import Foundation

class ConsistentHashValue<Value>: Hashable {
    private let __hashValue: Int
    let value: Value
    
    init(_ value: Value, hashValue: Int = UUID().hashValue) {
        __hashValue = hashValue
        self.value = value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(__hashValue)
    }
    
    static func == (lhs: ConsistentHashValue<Value>, rhs: ConsistentHashValue<Value>) -> Bool {
        return lhs.__hashValue == rhs.__hashValue
    }
}
