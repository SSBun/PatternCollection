//
//  PatternGroup.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/6.
//

import Foundation

// MARK: - PatternTag

class PatternTag {
    let id: String
    var name: String
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - ClothingPattern

class ClothingPattern {
    let id: String
    var name: String
    var description: String
    var image: String?
    var tags: [PatternTag]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        image: String? = nil,
        tags: [PatternTag]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.tags = tags
    }
}

// MARK: - PatternGroup

class PatternGroup {
    let id: String
    var name: String
    var patterns: [ClothingPattern]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        patterns: [ClothingPattern]
    ) {
        self.id = id
        self.name = name
        self.patterns = patterns
    }
}

// MARK: - PatternStorage

class PatternStorage {
    static let shared = PatternStorage()
    
    var groups: [PatternGroup] = []
    
    private init() {
        groups = mockData()
        // Mock data
    }
    
    private func mockData() -> [PatternGroup] {
        let tag1 = PatternTag(name: "tag1")
        let tag2 = PatternTag(name: "tag2")
        
        var result: [PatternGroup] = []
        
        for i in 0 ... 3 {
            var patterns: [ClothingPattern] = []
            for j in 0 ... 6 {
                let pattern1 = ClothingPattern(
                    name: "pattern \(i)-\(j)",
                    description: "pattern1 description",
                    tags: [tag1, tag2]
                )
                patterns.append(pattern1)
            }
            let group = PatternGroup(
                name: "group \(i)",
                patterns: patterns
            )
            result.append(group)
        }
        
        return result
    }
}
