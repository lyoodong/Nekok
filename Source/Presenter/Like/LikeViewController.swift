//
//  LikeViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import RealmSwift
import Kingfisher

class LikeViewController: BaseViewController {
    
    //Realm에서 받은 데이터를 저장
    var likedShoppingList: Results<RealmModel>? {
        didSet {
            likeView.searchCollectionView.reloadData()
        }
    }
    
    //페이지 카운트
    var pageCnt:Int = 1 {
        didSet {
            likeView.searchCollectionView.reloadData()
        }
    }
    
    //MARK: - UI property
    
    //메인뷰
    let likeView = ReusableMainView()
    
    //seerchBar를 넣을 UISearchController
    let searchController = UISearchController()
    
    //정렬 버튼 배열
    lazy var buttons: [UIButton] = [likeView.accuracyButton, likeView.dateButton, likeView.priceHighButton, likeView.priceLowButton]
    
    //네비게이션 타이틀
    lazy var naviTitle:UILabel = {
        let view = UILabel()
        view.text = "좋아요 목록"
        view.font = .bold16
        return view
    }()
    
    //Realm 호출
    let repo = LDRealm()
    
    //MARK: - Define method
    override func loadView() {
        view = likeView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callRealmDB()
    }
    
    //Realm의 데이터를 likedShoppingList에 저장
    func callRealmDB() {
        likedShoppingList = repo.read(object: RealmModel.self)
    }
    
    override func viewSet() {
        hiddenButtons()
        likeCollectionViewSet()
        navigationbarSet()
        searchControllerSet()
    }
    
    //버튼 히든 처리
    func hiddenButtons() {
        buttons.forEach { $0.isHidden = true }
        likeView.accuracyButton.snp.makeConstraints {
            $0.height.equalTo(0)
        }
    }
    
    //메인 컬랙션 뷰 세팅
    func likeCollectionViewSet() {
        likeView.searchCollectionView.delegate = self
        likeView.searchCollectionView.dataSource = self
    }
    
    //네비바 세팅
    func navigationbarSet() {
        navigationItem.titleView = naviTitle
        navigationItem.backButtonTitle = naviTitle.text
    }
    
    //서치바 세팅
    func searchControllerSet() {
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "검색어를 입력해주세요."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .systemPink
        searchController.searchBar.barStyle = .black
        navigationItem.searchController = searchController
    }
}

extension LikeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let likedShoppingList else { return 0 }
        return likedShoppingList.count
    }
    
    //셀 등록
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCollectionViewCell.IDF, for: indexPath) as? ReusableCollectionViewCell else { return UICollectionViewCell() }
        
        //likedShoppingList 데이터 할당
        guard let likedShoppingList else { return UICollectionViewCell() }
        let title = likedShoppingList[indexPath.row].title
        let price = likedShoppingList[indexPath.row].lprice
    
        //Cell에 데이터 할당
        cell.productTitle.text = StringHelper.removepHTMLTags(from: title)
        cell.productMallName.text = "[ \(likedShoppingList[indexPath.row].mallName) ]"
        cell.productLprice.text = StringHelper.commaSeparator(price: price)
        
        let imageLink = likedShoppingList[indexPath.row].image
        DispatchQueue.global().async {
            if let url = URL(string: imageLink) {
                DispatchQueue.main.async {
                    cell.productImageView.kf.setImage(with: url)
                }
            }
        }
        
        let result = likedShoppingList[indexPath.row]
        let item = Item(title: result.title, link: result.link, image: result.image, lprice: result.lprice, mallName: result.mallName, productID: result.productID, isLiked: result.isLiked)
        cell.shoppingList(item: item)
        cell.productLikeButton.isSelected = likedShoppingList[indexPath.row].isLiked
        
        return cell
    }
    
    //샐 클릭
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let likedShoppingList else { return }
        
        let productID = likedShoppingList[indexPath.row].productID
        let productTitle = likedShoppingList[indexPath.row].title
        let url = "https://msearch.shopping.naver.com/product/" + productID
        
        let vc = DetailViewController()
        vc.urlString = url
        vc.naviTitle.text = StringHelper.removepHTMLTags(from: productTitle)
        
        let result = likedShoppingList[indexPath.row]
        let item = Item(title: result.title, link: result.link , image: result.image, lprice: result.lprice, mallName: result.mallName, productID: result.productID)
    
        vc.selectedData = item
        LDTransition(viewController: vc, style: .push)
    }
}

extension LikeViewController: UISearchBarDelegate {
    
    //실시간 검색
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            callRealmDB()
        } else {
            repo.filter(searchBar: searchBar) { result in
                self.likedShoppingList = result
            }
        }
    }
    
    //취소 버튼 클릭
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        callRealmDB()
    }
    
    //검색 버튼 클릭
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        repo.filter(searchBar: searchBar) { result in
            self.likedShoppingList = result
        }
    }
}
