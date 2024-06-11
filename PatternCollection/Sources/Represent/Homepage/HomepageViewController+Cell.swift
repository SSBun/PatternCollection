//
//  HomepageViewController+Cell.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/6.
//

import Pillar
import UIKit

extension HomepageViewController {
    class PatternCell: NiblessCollectionViewCell {
        private let patternCard = ClothingPatternCard()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.backgroundColor = .secondarySystemGroupedBackground
            contentView.layer.cornerRadius = 6
            
            contentView.addSubview(patternCard)
            patternCard.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        func update(item: Item) {
            guard case let .pattern(pattern) = item.content else {
                return
            }
            patternCard.contentData = pattern.value
        }
    }
}

extension HomepageViewController {
    class PatternAddCell: NiblessCollectionViewCell {
        private lazy var addPatternButton = UIButton(type: .system).then {
            $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            $0.tintColor = .systemBlue
        }
        
        var addPatternHandler: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.backgroundColor = .secondarySystemGroupedBackground
            contentView.layer.cornerRadius = 6
            
            contentView.addSubview(addPatternButton)
            addPatternButton.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            addPatternButton.addAction(UIAction(handler: { [weak self] _ in
                self?.addPatternHandler?()
            }), for: .touchUpInside)
        }
    }
}
