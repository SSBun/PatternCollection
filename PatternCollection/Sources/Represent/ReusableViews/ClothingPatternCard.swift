//
//  ClothingPatternCard.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/6.
//

import UIKit
import Pillar

class ClothingPatternCard: NiblessView {
    var contentData: ClothingPattern? {
        didSet {
            updateContent()
        }
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textColor = .label
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func updateContent() {
        guard let contentData else { return }
        
        titleLabel.text = contentData.name
    }
}
