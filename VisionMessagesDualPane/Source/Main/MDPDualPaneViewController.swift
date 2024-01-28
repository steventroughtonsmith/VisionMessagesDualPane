//
//  MDPDualPaneViewController.swift
//  VisionMessagesDualPane
//
//  Created by Steven Troughton-Smith on 28/01/2024.
//

import UIKit
import SwiftUI

class MDPDualPaneViewController: UIViewController, ObservableObject {
	
	let padding = CGFloat(20)
	
	var auxiliaryController:UIHostingController<AuxiliaryPane>? = nil
	let mainController = MDPMainViewController()
	let mainNavigationController:UINavigationController
	
	// MARK: -
	
	init() {
		mainNavigationController = UINavigationController(rootViewController: mainController)
		
		super.init(nibName: nil, bundle: nil)
		
		auxiliaryController = UIHostingController(rootView: AuxiliaryPane(parentViewController: self))
		
		mainController.button.addTarget(self, action: #selector(togglePane(_:)), for: .touchUpInside)
		
		
		addChild(mainNavigationController)
		view.addSubview(mainNavigationController.view)
		
		addChild(auxiliaryController!)
		view.addSubview(auxiliaryController!.view)

	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: -
	
	@Published var isShowingBothPanes = false {
		didSet {
			
			view.setNeedsLayout()

			UIView.animate(withDuration: 0.3) { [weak self] in
				self?.view.layoutIfNeeded()
			}
			
			_updateWindowGeometry()
		}
	}
	
	@objc func togglePane(_ sender:Any?) {
		isShowingBothPanes.toggle()
	}
	
	// MARK: - Window Geometry
	
	func _updateWindowGeometry() {
		#if os(visionOS)
		/*
		 This is quick and dirty, and it would make more sense to locate this code at your window scene level
		 */
		guard let window = view.window else { return }
		guard let scene = window.windowScene else { return }
		
		let geo = UIWindowScene.GeometryPreferences.Vision()
		
		geo.size = window.bounds.size
		
		if isShowingBothPanes {
			geo.size?.width += MDPAuxiliaryPaneViewController.auxiliaryPaneWidth + padding
		}
		else {
			geo.size?.width -= MDPAuxiliaryPaneViewController.auxiliaryPaneWidth + padding
		}
		
		scene.requestGeometryUpdate(geo)
		#endif
	}
	
	// MARK: - Layout
	
	override func viewDidLayoutSubviews() {
		let division = view.bounds.divided(atDistance: MDPAuxiliaryPaneViewController.auxiliaryPaneWidth+padding, from: .maxXEdge)
		
		mainNavigationController.view.frame = isShowingBothPanes ? division.remainder : view.bounds
		auxiliaryController?.view.frame = division.slice.divided(atDistance: padding, from: .minXEdge).remainder
	}
	
#if os(visionOS)
	/* This view has no background glass, just empty space */
	override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
		return .hidden
	}
#endif
}
