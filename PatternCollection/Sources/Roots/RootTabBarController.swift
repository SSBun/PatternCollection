//
//  RootTabViewController.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/5.
//

import UIKit

final class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configChildren()
    }
    
    func configChildren() {
        func wrapNavigation(title: String, icon: UIImage, tag: Int, viewController: UIViewController) -> BaseNavigationController {
            let nav = BaseNavigationController(rootViewController: viewController)
            nav.tabBarItem = UITabBarItem(title: title, image: icon, tag: tag)
            return nav
        }
        
        let homepageVC = wrapNavigation(title: "版库", icon: Icons.person3Sequence.uiImage(), tag: 0, viewController: HomepageViewController())
        let mineVC = wrapNavigation(title: "我的", icon: Icons.person.uiImage(), tag: 1, viewController: MineViewController())
        
        viewControllers = [homepageVC, mineVC]
    }
}


#Preview {
    RootTabBarController()
}
