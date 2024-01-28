//
//  MDPMainViewController.swift
//  VisionMessagesDualPane
//
//  Created by Steven Troughton-Smith on 28/01/2024.
//  
//

import UIKit

final class MDPMainViewController: UIViewController {
	
	let button = UIButton(type: .system)

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "VisionMessagesDualPane"
		
		#if !os(visionOS)
		view.backgroundColor = .systemBackground
		#endif
		
		button.configuration = .borderedProminent()
		button.setTitle("Show Second Pane", for: .normal)
		
		view.addSubview(button)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	override func viewDidLayoutSubviews() {
		button.sizeToFit()
		button.frame = CGRect(x: (view.bounds.width-button.bounds.width)/2, y: (view.bounds.height-button.bounds.height)/2, width: button.bounds.width, height: button.bounds.height)
	}
}
