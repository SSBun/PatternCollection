//
//  BaseNavigationController.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/5.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show large title
        navigationBar.prefersLargeTitles = true
    }
}
