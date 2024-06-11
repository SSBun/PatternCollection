//
//  HomepageViewController+SectionHeader.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/6.
//

import Pillar
import UIKit

extension HomepageViewController {
    class SectionHeader: NiblessCollectionReusableVie {
        static let elementKind: String = "categoryHeader"
        
        var toggleHandler: (() -> Void)?
        
        private lazy var titleLabel = UILabel().then {
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.textColor = .label
        }
        
        private lazy var arrowIndicator = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
            
            addSubview(arrowIndicator)
            arrowIndicator.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(20)
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickBar))
            addGestureRecognizer(tapGesture)
        }
        
        @objc private func clickBar() {
            toggleHandler?()
        }
        
        func update(data: Section) {
            let arrowImage = data.isCollapsed ? Icons.arrowRight.uiImage() : Icons.arrowDown.uiImage()
            titleLabel.text = data.name
            arrowIndicator.setSymbolImage(arrowImage, contentTransition: .replace)
        }
    }
}
