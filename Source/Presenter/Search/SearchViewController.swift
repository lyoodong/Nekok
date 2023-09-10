//
//  SearchViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import Alamofire
import SnapKit

class SearchViewController: BaseViewController {
    //MARK: - Porperty
    var shoppingList:Result? {
        didSet {
            searchView.searchCollectionView.reloadData()
        }
    }
    
    var pageCnt:Int = 1 {
        didSet {
            searchView.searchCollectionView.reloadData()
        }
    }
    var currentSortType:SortType = .sim
    
    //MARK: - UI property
    let searchView = SearchView()
    let searchController = UISearchController()
    
    lazy var naviTitle:UILabel = {
        let view = UILabel()
        view.text = "쇼핑 검색"
        return view
    }()
    
    //MARK: - Define method
    override func loadView() {
        view = searchView
    }
    
    override func viewSet() {
        super.viewSet()
        searchCollectionViewSet()
        navigationbarSet()
        searchControllerSet()
        addtarget()
    }
    
    func callrequest(query:String, sortType: SortType, page:Int) {
        APIManager.shared.callRequest(query: query, sortType: sortType, page: page) { Result in
            let result = Result
            
            if self.shoppingList == nil {
                self.shoppingList = result
            } else {
                self.shoppingList?.items.append(contentsOf: result.items)
            }
        }
        
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
    
    @objc
    func searchbuttonClicked() {
        
    }
    
    @objc
    func likebuttonClicked() {
        
    }
    
    func searchCollectionViewSet() {
        searchView.searchCollectionView.delegate = self
        searchView.searchCollectionView.dataSource = self
        searchView.searchCollectionView.prefetchDataSource = self
    }
    
    func addtarget() {
        searchView.accuracyButton.addTarget(self, action: #selector(accuracyButtonClicked), for: .touchUpInside)
        searchView.dateButton.addTarget(self, action: #selector(dateButtonClicked), for: .touchUpInside)
        searchView.priceHighButton.addTarget(self, action: #selector(priceHighButtonClicked), for: .touchUpInside)
        searchView.priceLowButton.addTarget(self, action: #selector(priceLowButtonClicked), for: .touchUpInside)
    }
    
    func searchBarText() -> String {
        guard let searchText = searchController.searchBar.text else { return ""}
        return searchText
    }
    
        @objc func accuracyButtonClicked(_ sender: UIButton) {
            currentSortType = .sim
            shoppingList = nil
            changeButtonUI(sender)
            callrequest(query: searchBarText(), sortType: currentSortType, page: pageCnt)
        }
    
        @objc func dateButtonClicked(_ sender: UIButton) {
            currentSortType = .date
            shoppingList = nil
            changeButtonUI(sender)
            callrequest(query: searchBarText(), sortType: currentSortType, page: pageCnt)
        }
    
        @objc func priceHighButtonClicked(_ sender: UIButton) {
            currentSortType = .dsc
            shoppingList = nil
            changeButtonUI(sender)
            callrequest(query: searchBarText(), sortType: currentSortType, page: pageCnt)
        }
    
        @objc func priceLowButtonClicked(_ sender: UIButton) {
            currentSortType = .asc
            shoppingList = nil
            changeButtonUI(sender)
            callrequest(query: searchBarText(), sortType: currentSortType, page: pageCnt)
        }
    
        func changeButtonUI(_ sender: UIButton) {
            let buttons: [UIButton] = [searchView.accuracyButton, searchView.dateButton, searchView.priceHighButton, searchView.priceLowButton]
            if searchController.searchBar.text == "" {
                sender.isEnabled = false
            } else {
                sender.isEnabled = true
                sender.isSelected.toggle()
                if sender.isSelected {
                    sender.setTitleColor(.black, for: .normal)
                    sender.backgroundColor = .white
    
                } else {
                    sender.setTitleColor(.gray, for: .normal)
                    sender.backgroundColor = .black
                }
    
                   for button in buttons {
                       if button != sender {
                           button.isSelected = false
                           button.setTitleColor(.gray, for: .normal)
                           button.backgroundColor = .black
                       }
                   }
            }
        }
    
}

//MARK: - Extension
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoppingList?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCollectionViewCell.IDF, for: indexPath) as? ReusableCollectionViewCell else { return UICollectionViewCell() }
        
        guard let title = shoppingList?.items[indexPath.row].title
        else { return UICollectionViewCell() }
        
        cell.productTitle.text = StringHelper.removepHTMLTags(from: title)
        cell.productMallName.text = shoppingList?.items[indexPath.row].mallName
        
        guard let price = shoppingList?.items[indexPath.row].lprice
        else { return UICollectionViewCell() }
        
        cell.productLprice.text = StringHelper.commaSeparator(price: price)
        
        DispatchQueue.global().async {
            if let url = URL(string: self.shoppingList?.items[indexPath.row].image ?? ""){
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
        
        guard let productID = shoppingList?.items[indexPath.row].productID else { return }
        let url = "https://msearch.shopping.naver.com/product/" + productID
        
        guard let productTitle = shoppingList?.items[indexPath.row].title else { return }
        let vc = DetailViewController()
        vc.urlString = url
        vc.naviTitle.text = StringHelper.removepHTMLTags(from: productTitle)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        guard let shoppingItemCnt = shoppingList?.items.count else { return }
        
        for indexPath in indexPaths {
            if indexPath.row == shoppingItemCnt - 1 && pageCnt < 100 {
                pageCnt += 1
                print(pageCnt)
                callrequest(query: searchBarText(), sortType: currentSortType, page: pageCnt)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("===== 빠른 스크롤 중 \(indexPaths) =====")
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        callrequest(query: query, sortType: currentSortType, page: 1)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.shoppingList = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        callrequest(query: query, sortType: currentSortType, page: 1)
//        let buttons: [UIButton] = [searchView.accuracyButton, searchView.dateButton, searchView.priceHighButton, searchView.priceLowButton]
//        buttons.forEach { UIButton in
//            UIButton.isHidden = false
//        }
    }
}

