//
//  DetailViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import WebKit
import SnapKit

class DetailViewController: BaseViewController {
    //MARK: - Porperty
    var isLiked:Bool = true
    var urlString:String?
    //MARK: - UIporperty
    var webView = WKWebView()
    
    lazy var naviTitle:UILabel = {
        let view = UILabel()
        return view
    }()

    lazy var likeButton:UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.target = self
        view.action = #selector(likeButtonClicked)
        return view
    }()
    
    //MARK: - Define method
    override func viewWillAppear(_ animated: Bool) {
        likeImageSet()
    }
    
    @objc func likeButtonClicked() {
        isLiked.toggle()
        likeImageSet()
    }
    
    func likeImageSet() {
        if isLiked {
            likeButton.image = UIImage(systemName: "heart.fill")?.withTintColor(.white)
        } else {
            likeButton.image = UIImage(systemName: "heart")
        }
    }
    
    override func viewSet() {
        navigationbarSet()
        tabBarSet()
        webViewSet()
    }
    
    func webViewSet() {
        guard let urlString else { return }
        let url = URL(string: urlString)
        
        guard let url else { return }
        let request = URLRequest(url: url)
        
        webView.load(request)
        view.addSubview(webView)
    }
    
    func navigationbarSet() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationItem.titleView = naviTitle
        navigationItem.rightBarButtonItem = likeButton

    }
    
    func tabBarSet() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .black
        tabBarController?.tabBar.standardAppearance = appearance
    }
    
    override func constraints() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        naviTitle.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.4)
        }
    }
}
