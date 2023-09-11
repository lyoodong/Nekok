//
//  DetailViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import WebKit
import RealmSwift
import SnapKit

class DetailViewController: BaseViewController {
    //MARK: - Porperty
    
    //현재 좋아요 상태
    var isLiked:Bool = false {
        didSet {
            likeImageSet()
        }
    }

    var urlString:String?
    
    //Realm Repository
    let repo = LDRealm()
    
    //productID
    var productID = ""
    
    //MARK: - UIporperty
    
    //WEBVIEW
    var webView = WKWebView()
    
    //네비게이션 타이틀
    lazy var naviTitle:UILabel = {
        let view = UILabel()
        return view
    }()
    
    //좋아요 버튼
    lazy var likeButton:UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.target = self
        view.action = #selector(likeButtonClicked)
        return view
    }()
    
    //MARK: - Define method
    override func viewWillAppear(_ animated: Bool) {
        checkLike()
        likeImageSet()
    }
    
    @objc func likeButtonClicked() {
        isLiked.toggle()
        likeImageSet()
        changeLike()
    }
    
    //좋아요 상태 변경
    func changeLike() {
        let realm = try! Realm()

        try! realm.write {
            let item = repo.readByPrimaryKey(object: RealmModel.self, productID: productID)
            item.isLiked = isLiked
            
            if isLiked {
                repo.write(object: item, writetype: .update)
                repo.getRealmLocation()
            } else {
                let deleteObject = repo.searchDeleteObject(key: item.productID)
                realm.delete(deleteObject)
            }
        }
    }
    
    //좋아요 상태 검사
    func checkLike() {
        print(productID)
        let item = repo.readByPrimaryKey(object: RealmModel.self, productID: productID)
        print(item.isLiked)
        isLiked = item.isLiked
    }
    
    //좋아요 상태에 따른 버튼 이미지
    func likeImageSet() {
        if isLiked {
            likeButton.image = UIImage(systemName: "heart.fill")?.withTintColor(.white)
        } else {
            likeButton.image = UIImage(systemName: "heart")
        }
    }
    
    
    override func viewSet() {
        webViewSet()
        navigationbarSet()
        tabBarSet()
    }
    
    //웹뷰 세팅
    func webViewSet() {
        guard let urlString else { return }
        let url = URL(string: urlString)
        
        guard let url else { return }
        let request = URLRequest(url: url)
        
        webView.load(request)
        view.addSubview(webView)
    }
    
    //네비바 세팅
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
    
    //탭바 세팅
    func tabBarSet() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .black
        tabBarController?.tabBar.standardAppearance = appearance
    }
    
    //오토레이아웃
    override func constraints() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        naviTitle.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.4)
        }
    }
}
