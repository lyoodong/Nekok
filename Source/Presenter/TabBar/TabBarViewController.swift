//
//  TabBarViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/08.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let search = SearchViewController()
    let like = SearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        viewSet()
    }

    func viewSet(){
        addViewControllers()
        self.tabBar.tintColor = .systemPink
        self.tabBar.unselectedItemTintColor = .white
    }
    
    func addViewControllers() {
        let searchTab = createViewController(title: "검색", imageName: "magnifyingglass", viewController: search)
        let likeTab = createViewController(title: "좋아요", imageName: "heart", viewController: like)
        self.viewControllers = [searchTab, likeTab]
    }
    
    func createViewController(title: String, imageName: String, viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        let image = UIImage(systemName:imageName)
        nav.tabBarItem.image = image
        nav.tabBarItem.title = title

        return nav
    }
}
