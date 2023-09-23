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
    var isLiked:Bool = false
    
    //상품 Url
    var urlString:String?
    
    //Realm Repository
    let repo = LDRealm()

    //이전 페이지에서 선택된 아이템
    var selectedData: Item?
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
        print(isLiked)
        ConvertData.shared.likeImageSet(likeButton, isLiked: isLiked)
    }
    
    @objc func likeButtonClicked() {
        isLiked.toggle()
        selectedData?.isLiked = isLiked
        
        guard let selectedData = selectedData else { return }
        let productID = selectedData.productID
        
        ConvertData.shared.changeButtonStatus(object: ConvertData.shared.toRealmModel(selectedData), key: productID, isLiked: isLiked)
        ConvertData.shared.likeImageSet(likeButton, isLiked: isLiked)
    }
    
    override func viewSet() {
        webViewSet()
        navigationbarSet()
        tabBarSet()
        checkLike()
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
        ConvertData.shared.likeImageSet(likeButton, isLiked: isLiked)
        
    }
    
    //탭바 세팅
    func tabBarSet() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .black
        tabBarController?.tabBar.standardAppearance = appearance
    }
    
    //좋아요 상태 검사
    func checkLike() {
        guard let selectedData = selectedData else { return }
        let item = ConvertData.shared.toRealmModel(selectedData)
        let itemIsLiked = ConvertData.shared.currentLikeStatus(productID: item.productID)
        isLiked = itemIsLiked
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
