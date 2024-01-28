//
//  MDPAuxiliaryPaneViewController.swift
//  VisionMessagesDualPane
//
//  Created by Steven Troughton-Smith on 28/01/2024.
//

import UIKit
import SwiftUI

// MARK: - SwiftUI that does the z animation in 3D space

struct AuxiliaryPane: View {
	
	@ObservedObject var parentViewController:MDPDualPaneViewController
	
	var body: some View {
		AuxiliaryPaneWrapper(parentViewController: parentViewController)
#if os(visionOS)
			.offset(z: parentViewController.isShowingBothPanes ? 0 : -64)
#endif
			.opacity(parentViewController.isShowingBothPanes ? 1.0 : 0.0)
			.animation(.spring, value: parentViewController.isShowingBothPanes)
	}
}

// MARK: - SwiftUI wrapper for UIKit content view controller

struct AuxiliaryPaneWrapper: UIViewControllerRepresentable {
	var parentViewController:MDPDualPaneViewController
	
	func makeUIViewController(context: Context) -> some UIViewController {
		let vc = MDPAuxiliaryPaneViewController()
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: parentViewController, action: #selector(MDPDualPaneViewController.togglePane(_:)))
		let nc = UINavigationController(rootViewController: vc)
		
		return nc
	}
	
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
		
	}
}

// MARK: - UIKit content view controller

class MDPAuxiliaryPaneViewController: UICollectionViewController {
	
	static let auxiliaryPaneWidth = CGFloat(320)
	
	// MARK: - Everything below this point is not important for this example
	
	enum Section {
		case main
	}
	
	struct Item: Hashable {
		var identifier = UUID().uuidString
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(identifier)
		}
		
		static func == (lhs: Item, rhs: Item) -> Bool {
			return lhs.identifier == rhs.identifier
		}
	}
	
	typealias ItemType = Item
	
	let reuseIdentifier = "Cell"
	var dataSource: UICollectionViewDiffableDataSource<Section, ItemType>! = nil
	var currentItems:[ItemType] = []
	
	let padding = CGFloat(20)
	
	init() {
		let layout = UICollectionViewFlowLayout()
		
		super.init(collectionViewLayout: layout)
		guard let collectionView = collectionView else { return }
		
#if !os(visionOS)
		view.backgroundColor = .systemBackground
#endif
		
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		if #available(iOS 15.0, *) {
			collectionView.allowsFocus = true
		}
		
		collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
		
		configureDataSource()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Layout
	
	override func viewDidLayoutSubviews() {
		var columns = 2
		let maxWidth = CGFloat(200)
		
		guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
		
		while view.bounds.size.width/CGFloat(columns) > maxWidth
		{
			columns += 1
		}
		
		let usableWidth = collectionView.bounds.width-collectionView.contentInset.left-collectionView.contentInset.right
		let itemSize = (usableWidth - padding*((CGFloat(columns-1)))) / CGFloat(columns)
		
		layout.itemSize = CGSize(width: itemSize, height: itemSize)
		layout.minimumLineSpacing = padding
	}
	
	// MARK: - Data Source
	
	func configureDataSource() {
		
		dataSource = UICollectionViewDiffableDataSource<Section, ItemType>(collectionView: collectionView) {
			(collectionView: UICollectionView, indexPath: IndexPath, item: ItemType) -> UICollectionViewCell? in
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath)
			
			var config = UIListContentConfiguration.cell()
			
			config.text = "Cell"
			config.textProperties.alignment = .center
			
			cell.contentConfiguration = config
			
			var bg = UIBackgroundConfiguration.listPlainCell()
			bg.cornerRadius = CGFloat(8)
			bg.backgroundColor = .systemFill
			cell.backgroundConfiguration = bg
			
			return cell
		}
		
		collectionView.dataSource = dataSource
		
		refresh()
	}
	
	func snapshot() -> NSDiffableDataSourceSectionSnapshot<ItemType> {
		var snapshot = NSDiffableDataSourceSectionSnapshot<ItemType>()
		
		for _ in 0 ..< 9 {
			currentItems.append(ItemType())
		}
		
		snapshot.append(currentItems)
		
		return snapshot
	}
	
	func refresh() {
		guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<Section, ItemType> else { return }
		
		dataSource.apply(snapshot(), to: .main, animatingDifferences: false)
	}
	
}
