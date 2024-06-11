//
//  File.swift
//  
//
//  Created by caishilin on 2024/6/5.
//

import Foundation

public protocol Thenable {
}

extension Thenable where Self: Any {
    @discardableResult
    public func then(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}
