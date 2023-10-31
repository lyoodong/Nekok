//
//  TabBarViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/08.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    //추가할 VC
    let search = SearchViewController()
    let like = LikeViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        viewSet()
    }
    
    //탭바 설정
    func viewSet(){
        addViewControllers()
        self.tabBar.tintColor = .nGreen
        self.tabBar.unselectedItemTintColor = .white
    }
    
    //탭바에 VC추가
    func addViewControllers() {
        let searchTab = createViewController(title: "검색", imageName: "magnifyingglass", viewController: search)
        let likeTab = createViewController(title: "좋아요", imageName: "heart", viewController: like)
        self.viewControllers = [searchTab, likeTab]
    }
    
    //VC에 네비게이션 컨트롤러 연결 및 각 탭에 대한 이미지 설정
    func createViewController(title: String, imageName: String, viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        let image = UIImage(systemName:imageName)
        nav.tabBarItem.image = image
        nav.tabBarItem.title = title

        return nav
    }
}
