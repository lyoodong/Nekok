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
    
    //MARK: - UI property
    let searchView = SearchView()
    
    //MARK: - Define method
    override func loadView() {
        view = searchView
    }
    
    override func viewSet() {
        super.viewSet()
        callrequest()
        navigationbarSet()
        searchCollectionViewSet()
        addtarget()
    }
    
    func callrequest() {
        APIManager.shared.callRequest(query: "캠핑", sortType: .sim) { Result in
            self.shoppingList = Result
        }
    }
    
    func navigationbarSet() {
        navigationItem.title = "쇼핑 검색"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    
    }
    
    func searchCollectionViewSet() {
        searchView.searchCollectionView.delegate = self
        searchView.searchCollectionView.dataSource = self
    }
    
    func addtarget() {
        searchView.cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        searchView.accuracyButton.addTarget(self, action: #selector(accuracyButtonClicked), for: .touchUpInside)
        searchView.dateButton.addTarget(self, action: #selector(dateButtonClicked), for: .touchUpInside)
        searchView.priceHighButton.addTarget(self, action: #selector(priceHighButtonClicked), for: .touchUpInside)
        searchView.priceLowButton.addTarget(self, action: #selector(priceLowButtonClicked), for: .touchUpInside)
    }
    
    @objc func cancelButtonClicked() {
        
    }
    
    @objc func accuracyButtonClicked() {
        
    }
    
    @objc func dateButtonClicked() {
        
    }
    
    @objc func priceHighButtonClicked() {
        
    }
    
    @objc func priceLowButtonClicked() {
        
    }
    
}

//MARK: - Extension
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoppingList?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCollectionViewCell.IDF, for: indexPath) as? ReusableCollectionViewCell else { return UICollectionViewCell() }
        
        cell.productTitle.text = shoppingList?.items[indexPath.row].title
        cell.productMallName.text = shoppingList?.items[indexPath.row].mallName
        cell.productLprice.text = shoppingList?.items[indexPath.row].lprice
        
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
        
    }
}
