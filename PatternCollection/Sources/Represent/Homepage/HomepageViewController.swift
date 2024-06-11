//
//  HomepageViewController.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/5.
//

import Pillar
import SnapKit
import UIKit

// MARK: - HomepageViewController

final class HomepageViewController: BaseViewController {
    private lazy var collectionLayout: UICollectionViewCompositionalLayout = configCollectionLayout()
    private lazy var collectionView: UICollectionView = configCollectionView()
    private lazy var dataSource: DataSource = configDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "版库"
        
        layoutCollectionView()
        updateDataSource()
    }
    
    private func layoutCollectionView() {
        collectionView.backgroundColor = .systemGroupedBackground
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func updateDataSource() {
        let groups = PatternStorage.shared.groups
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        for group in groups {
            let section = Section(name: group.name, group: .init(group))
            snapshot.appendSections([section])
            let items = group.patterns.map({ Item(id: $0.id, content: .pattern(.init($0))) })
            snapshot.appendItems(items, toSection: section)
            let addItem = Item(id: UUID().uuidString, content: .addNewPattern)
            snapshot.appendItems([addItem], toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configCollectionLayout() -> UICollectionViewCompositionalLayout {
        // Configures layouts
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        let collectionLayout = UICollectionViewCompositionalLayout(sectionProvider: { section, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
            layoutItem.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.4))
            let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: layoutItem, count: 4)
            layoutGroup.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: SectionHeader.elementKind, alignment: .top
            )
            //            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            //                layoutSize: headerFooterSize,
            //                elementKind: "footer", alignment: .bottom)
            layoutSection.boundarySupplementaryItems = [sectionHeader]
            
            return layoutSection
        }, configuration: layoutConfig)
        return collectionLayout
    }
    
    private func configDataSource() -> DataSource {
        // Cell
        let resourceCellRegistration = UICollectionView.CellRegistration<PatternCell, Item> { cell, indexPath, item in
            cell.update(item: item)
        }
        
        // Add cell
        let addCellRegistration = UICollectionView.CellRegistration<PatternAddCell, Item> { cell, indexPath, item in
            cell.addPatternHandler = { [weak self] in
                guard let self else { return }
                
                var snapshot = dataSource.snapshot()
                let newPattern = ClothingPattern(name: "New Pattern", description: "New Pattern Description", tags: [])
                let newItem = Item(id: UUID().uuidString, content: .pattern(.init(newPattern)))
                snapshot.insertItems([newItem], beforeItem: item)
                dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
        
        // Header
        let headerRegistration = UICollectionView.SupplementaryRegistration<SectionHeader>(elementKind: SectionHeader.elementKind) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self else { return }
            
            supplementaryView.toggleHandler = { [weak self] in
                guard let self, var actionSection = dataSource.sectionIdentifier(for: indexPath.section) else { return }
                
                let snapshot = dataSource.snapshot()
                
                var newSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                
                for section in snapshot.sectionIdentifiers {
                    if section == actionSection {
                        if actionSection.isCollapsed {
                            actionSection.isCollapsed.toggle()
                            newSnapshot.appendSections([actionSection])
                            var items = PatternStorage.shared.groups[indexPath.section].patterns.map({ Item(id: $0.id, content: .pattern(.init($0))) })
                            items.append(Item(id: UUID().uuidString, content: .addNewPattern))
                            newSnapshot.appendItems(items, toSection: actionSection)
                        } else {
                            actionSection.isCollapsed.toggle()
                            newSnapshot.appendSections([actionSection])
                        }
                    } else {
                        let items = snapshot.itemIdentifiers(inSection: section)
                        newSnapshot.appendSections([section])
                        newSnapshot.appendItems(items, toSection: section)
                    }
                }
                dataSource.apply(newSnapshot, animatingDifferences: true)
            }
            
            if let section = dataSource.sectionIdentifier(for: indexPath.section) {
                supplementaryView.update(data: section)
            }
        }
        
        // Configures data source
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.content {
            case .addNewPattern:
                collectionView.dequeueConfiguredReusableCell(using: addCellRegistration, for: indexPath, item: item)
            case .pattern:
                collectionView.dequeueConfiguredReusableCell(using: resourceCellRegistration, for: indexPath, item: item)
            }
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        dataSource.reorderingHandlers.canReorderItem = { [weak dataSource] item in
            guard let dataSource else { return false }
            
            let snapshot = dataSource.snapshot()
            guard let section = snapshot.sectionIdentifier(containingItem: item) else { return false }
            let itemCount = snapshot.numberOfItems(inSection: section)
            
            guard let indexPath = dataSource.indexPath(for: item) else { return false }
            
            if indexPath.item == itemCount - 1 { return false }
            
            return true
        }
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            guard let self else { return }
            
            updatePatternStorage(transaction.finalSnapshot)
        }
        collectionView.dataSource = dataSource
        return dataSource
    }
    
    private func configCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        return collectionView
    }
    
    private func updatePatternStorage(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>) {
        for section in snapshot.sectionIdentifiers where !section.isCollapsed {
            section.group.value.patterns = snapshot.itemIdentifiers(inSection: section).compactMap({
                if case let .pattern(pattern) = $0.content {
                    return pattern.value
                } else {
                    return nil
                }
            })
        }
    }
}

// MARK: HomepageViewController.DataSource

extension HomepageViewController {
    fileprivate class DataSource: UICollectionViewDiffableDataSource<Section, Item> {}
}

// MARK: UICollectionViewDragDelegate

extension HomepageViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        []
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let previewParameters = UIDragPreviewParameters()
        let cardRect = collectionView.layoutAttributesForItem(at: indexPath)?.bounds ?? .zero
        previewParameters.visiblePath = UIBezierPath(roundedRect: cardRect, cornerRadius: 6)
        return previewParameters
    }
}

// MARK: UICollectionViewDropDelegate

extension HomepageViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {}
    
    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let previewParameters = UIDragPreviewParameters()
        let cardRect = collectionView.layoutAttributesForItem(at: indexPath)?.bounds ?? .zero
        previewParameters.visiblePath = UIBezierPath(roundedRect: cardRect, cornerRadius: 6)
        return previewParameters
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard let destinationIndexPath else { return UICollectionViewDropProposal(operation: .cancel) }
        
        guard let section = dataSource.sectionIdentifier(for: destinationIndexPath.section) else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        let itemCount = dataSource.snapshot().numberOfItems(inSection: section)
        
        if destinationIndexPath.item == itemCount - 1 {
            // Prevent dropping on the "Add Item" cell
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

extension HomepageViewController {
    struct Section: Hashable {
        let name: String
        let group: ConsistentHashValue<PatternGroup>
        var id: String { group.value.id }
        var isCollapsed: Bool = false
    }
    
    enum ItemContent: Hashable {
        case addNewPattern
        case pattern(ConsistentHashValue<ClothingPattern>)
    }
    
    struct Item: Hashable {
        let id: String
        let content: ItemContent
    }
}

#Preview {
    HomepageViewController()
}
