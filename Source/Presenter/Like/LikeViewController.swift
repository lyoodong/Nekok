//
//  LikeViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit

class LikeViewController: BaseViewController {
    //MARK: - property
    var likedShoppingList:Result? {
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
        return view
    }()
    
    //MARK: - Define method
    override func loadView() {
        view = likeView
        hiddenButtons()
    }
    
    override func viewSet() {
        likeCollectionViewSet()
        navigationbarSet()
        searchControllerSet()
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
    
    func hiddenButtons() {
        let buttons:[UIButton] = [likeView.accuracyButton, likeView.dateButton, likeView.priceHighButton, likeView.priceLowButton]
        
        buttons.forEach { UIButton in
            UIButton.isHidden = true
        }
    }
    
    func searchBarText() -> String {
        guard let searchText = searchController.searchBar.text else { return ""}
        return searchText
    }
    
    override func constraints() {
       
    }

}

extension LikeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedShoppingList?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCollectionViewCell.IDF, for: indexPath) as? ReusableCollectionViewCell else { return UICollectionViewCell() }
        
        guard let title = likedShoppingList?.items[indexPath.row].title
        else { return UICollectionViewCell() }
        
        cell.productTitle.text = StringHelper.removepHTMLTags(from: title)
        cell.productMallName.text = likedShoppingList?.items[indexPath.row].mallName
        
        guard let price = likedShoppingList?.items[indexPath.row].lprice
        else { return UICollectionViewCell() }
        
        cell.productLprice.text = StringHelper.commaSeparator(price: price)
        
        DispatchQueue.global().async {
            if let url = URL(string: self.likedShoppingList?.items[indexPath.row].image ?? ""){
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
        
        guard let productID = likedShoppingList?.items[indexPath.row].productID else { return }
        let url = "https://msearch.shopping.naver.com/product/" + productID
        
        guard let productTitle = likedShoppingList?.items[indexPath.row].title else { return }
        let vc = DetailViewController()
        vc.urlString = url
        vc.naviTitle.text = StringHelper.removepHTMLTags(from: productTitle)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LikeViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.likedShoppingList = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    }
}
