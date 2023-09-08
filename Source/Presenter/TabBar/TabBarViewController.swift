//
//  TabBarViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/08.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    lazy var naviTitle:UILabel = {
        let view = UILabel()
        view.text = "검색화면"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSet()
    }

    func viewSet(){
        addViewControllers()
        setupSearchController()
        self.tabBar.tintColor = .systemPink
        self.tabBar.unselectedItemTintColor = .white
    }
    
    func addViewControllers() {
        let search = SearchViewController()
        let searchTab = createViewController(title: "검색", imageName: "magnifyingglass", viewController: search)
        let like = SearchViewController()
        let likeTab = createViewController(title: "좋아요", imageName: "heart", viewController: like)
        
        self.viewControllers = [searchTab, likeTab]
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색(placeholder)"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .systemPink
        navigationItem.searchController = searchController
    }
    
    func createViewController(title: String, imageName: String, viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        let image = UIImage(systemName:imageName)
        nav.tabBarItem.image = image
        nav.tabBarItem.title = title
        navigationItem.titleView = naviTitle
        return nav
    }
    
}
