//
//  LikeViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import RealmSwift

class LikeViewController: BaseViewController {
    var likedShoppingList: Results<RealmModel>? {
        didSet {
            likeView.searchCollectionView.reloadData()
        }
    }
    
    var pageCnt:Int = 1 {
        didSet {
            likeView.searchCollectionView.reloadData()
        }
    }
    
    //MARK: - UI property
    let likeView = SearchView()
    let searchController = UISearchController()
    
    lazy var naviTitle:UILabel = {
        let view = UILabel()
        view.text = "좋아요 목록"
        view.font = .bold16
        return view
    }()
    
    let repo = LDRealm()
    
    //MARK: - Define method
    override func loadView() {
        view = likeView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callRealmDB()
    }
    
    override func viewSet() {
        hiddenButtons()
        likeCollectionViewSet()
        navigationbarSet()
        searchControllerSet()
    }
    
    func callRealmDB() {
        likedShoppingList = repo.read(object: RealmModel.self)
    }
    
    func hiddenButtons() {
        let buttons:[UIButton] = [likeView.accuracyButton, likeView.dateButton, likeView.priceHighButton, likeView.priceLowButton]
        
        buttons.forEach { UIButton in
            UIButton.isHidden = true
        }
        likeView.accuracyButton.snp.makeConstraints {
            $0.height.equalTo(0)
        }
    }
    
    func likeCollectionViewSet() {
        likeView.searchCollectionView.delegate = self
        likeView.searchCollectionView.dataSource = self
    }
    
    func navigationbarSet() {
        navigationItem.titleView = naviTitle
        navigationItem.backButtonTitle = naviTitle.text
    }
    
    func searchControllerSet() {
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "검색어를 입력해주세요."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .systemPink
        searchController.searchBar.barStyle = .black
        navigationItem.searchController = searchController
    }
    
    func searchBarText() -> String {
        guard let searchText = searchController.searchBar.text else { return String().emptyStrng}
        return searchText
    }
    
    override func constraints() {
        
    }
    
}

extension LikeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let likedShoppingList else { return 0 }
        return likedShoppingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCollectionViewCell.IDF, for: indexPath) as? ReusableCollectionViewCell else { return UICollectionViewCell() }
        
        guard let likedShoppingList else { return UICollectionViewCell() }
        let title = likedShoppingList[indexPath.row].title
        
        cell.productTitle.text = StringHelper.removepHTMLTags(from: title)
        cell.productMallName.text = "[ \(likedShoppingList[indexPath.row].mallName) ]"
        
        let price = likedShoppingList[indexPath.row].lprice
        
        cell.productLprice.text = StringHelper.commaSeparator(price: price)
        
        guard let value = self.likedShoppingList?[indexPath.row].image else { return UICollectionViewCell() }
        DispatchQueue.global().async {
            if let url = URL(string: value){
                let data = try! Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    cell.productImageView.image = image
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let likedShoppingList else { return }
        
        let productID = likedShoppingList[indexPath.row].productID
        let url = "https://msearch.shopping.naver.com/product/" + productID
        
        let productTitle = likedShoppingList[indexPath.row].title
        let vc = DetailViewController()
        vc.urlString = url
        vc.naviTitle.text = StringHelper.removepHTMLTags(from: productTitle)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LikeViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == String().emptyStrng {
            callRealmDB()
        } else {
            repo.filter(searchBar: searchBar) { result in
                self.likedShoppingList = result
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        callRealmDB()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        repo.filter(searchBar: searchBar) { result in
            self.likedShoppingList = result
        }
    }
}
