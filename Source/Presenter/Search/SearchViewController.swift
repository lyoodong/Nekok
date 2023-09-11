//
//  SearchViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import Alamofire
import RealmSwift
import SnapKit


class SearchViewController: BaseViewController {
    //MARK: - Porperty
    
    //쇼핑 API에서 받은 데이터를 저장
    var shoppingList:Result? {
        didSet {
            searchView.searchCollectionView.reloadData()
        }
    }
    
    //페이지 카운트
    var pageCnt:Int = 1 {
        didSet {
            searchView.searchCollectionView.reloadData()
        }
    }
    //검색 타입
    var currentSortType:SortType = .sim
    
    //Realm Repository
    let repo = LDRealm()
    
    //Realm에서 좋아요 클릭한 상품 데이터 저장
    var likedShoppingList:Results<RealmModel>?
    
    //현재 상품의 좋아요 상태
    var currentLiked:Bool?

    //MARK: - UI property
    
    //메인뷰
    let searchView = ReusableMainView()
    
    //seerchBar를 넣을 UISearchController
    let searchController = UISearchController()
    
    //네비게이션 타이틀
    lazy var naviTitle:UILabel = {
        let view = UILabel()
        view.text = "쇼핑 검색"
        view.font = .bold16
        return view
    }()
    
    //MARK: - Define method
    override func loadView() {
        view = searchView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callRealmDB()
        resetButton()
    }
    
    //Realm의 데이터를 likedShoppingList에 저장
    func callRealmDB() {
        likedShoppingList = repo.read(object: RealmModel.self)
    }

    override func viewSet() {
        super.viewSet()
        searchCollectionViewSet()
        navigationbarSet()
        searchControllerSet()
        setSortType()
        addtarget()
    }
    
    //API 호출
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
    
    //메인 컬랙션 뷰 세팅
    func searchCollectionViewSet() {
        searchView.searchCollectionView.delegate = self
        searchView.searchCollectionView.dataSource = self
        searchView.searchCollectionView.prefetchDataSource = self
    }
    
    //정렬 타입 세팅
    func setSortType() {
        searchView.accuracyButton.sortType = .sim
        searchView.dateButton.sortType = .date
        searchView.priceHighButton.sortType = .dsc
        searchView.priceLowButton.sortType = .asc
    }

    //타겟 설정
    func addtarget() {
        searchView.accuracyButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        searchView.dateButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        searchView.priceHighButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        searchView.priceLowButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
    }

    //버튼 클릭 시 매서드
    @objc func buttonClicked(_ sender: UIButton) {
        if let sortType = sender.sortType {
            handleSortType(sortType)
        }
    }
    
    //정렬 타입에 따른 handling
    func handleSortType(_ sortType: SortType) {
        currentSortType = sortType
        shoppingList = nil
        changeButtonUI()
        callrequest(query: searchBarText(), sortType: currentSortType, page: pageCnt)
    }
    
    //정렬에 따른 button ui 변경
    func changeButtonUI() {
        let buttons: [UIButton] = [searchView.accuracyButton, searchView.dateButton, searchView.priceHighButton, searchView.priceLowButton]
        let searchBarIsEmpty = searchController.searchBar.text?.isEmpty ?? true
        
        for button in buttons {
            let sortType = button.sortType ?? .sim
            let isSelected = sortType == currentSortType
            button.isEnabled = !searchBarIsEmpty
            button.isSelected = isSelected
            button.setTitleColor(isSelected ? .black : .gray, for: .normal)
            button.backgroundColor = isSelected ? .white : .black
            
        }
    }
    
    //버튼 비활성화
    func resetButton() {
        let buttons: [UIButton] = [searchView.accuracyButton, searchView.dateButton, searchView.priceHighButton, searchView.priceLowButton]
        
        buttons.forEach { UIButton in
            UIButton.isSelected = false
            UIButton.setTitleColor(.gray, for: .normal)
            UIButton.backgroundColor = .black
            UIButton.isEnabled = false
        }
    }
    
    //버튼 활성화
    func restartButton() {
        let buttons: [UIButton] = [searchView.accuracyButton, searchView.dateButton, searchView.priceHighButton, searchView.priceLowButton]
        
        buttons.forEach { UIButton in
            UIButton.isEnabled = true
        }
    }

    //서치바에서 현재 검색하고 있는 텍스트
    func searchBarText() -> String {
        guard let searchText = searchController.searchBar.text else { return String().emptyStrng}
        return searchText
    }
}

//MARK: - Extension
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    //셀 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoppingList?.items.count ?? 0
    }
    
    //셀 등록
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCollectionViewCell.IDF, for: indexPath) as? ReusableCollectionViewCell else { return UICollectionViewCell() }
        
        //shoppingList 데이터 할당
        guard let title = shoppingList?.items[indexPath.row].title
        else { return UICollectionViewCell() }
        
        guard let productMallName = shoppingList?.items[indexPath.row].mallName
        else { return UICollectionViewCell() }
        
        guard let price = shoppingList?.items[indexPath.row].lprice
        else { return UICollectionViewCell() }
        
        guard let productID = shoppingList?.items[indexPath.row].productID
        else { return UICollectionViewCell() }
        
        let productTitle = StringHelper.removepHTMLTags(from: title)
        let productLprice = StringHelper.commaSeparator(price: price)
        
        cell.productTitle.text = productTitle
        cell.productMallName.text = "[ \(productMallName) ]"
        cell.productLprice.text = productLprice
        
        DispatchQueue.global().async {
            let imageLink = self.shoppingList?.items[indexPath.row].image ?? String().emptyStrng
            if let url = URL(string: imageLink){
                let data = try! Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    cell.productImageView.image = image
                    
                }
            }
        }
        
        //등록된 좋아요 물품 필터 로직
        guard let likedShoppingList else { return UICollectionViewCell() }
        var likedShoppingDict: [String: Bool] = [:]

        for item in likedShoppingList {
            likedShoppingDict[item.productID] = item.isLiked
        }

        if let productID = shoppingList?.items[indexPath.row].productID {
            if let isLiked = likedShoppingDict[productID] {
                shoppingList?.items[indexPath.row].isLiked = isLiked
            }
        }
        
        guard let isLikedCell = shoppingList?.items[indexPath.row].isLiked else { return UICollectionViewCell()}
        
        cell.productLikeButton.isSelected = isLikedCell
        currentLiked = cell.productLikeButton.isSelected
        
        guard let result = shoppingList?.items[indexPath.row] else { return UICollectionViewCell()}
        cell.shoppingList(item: result)
    
        return cell
    }
    
    //샐 클릭
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let productID = shoppingList?.items[indexPath.row].productID else { return }
        guard let productTitle = shoppingList?.items[indexPath.row].title else { return }
        guard let currentLiked else { return }
        
        let url = "https://msearch.shopping.naver.com/product/" + productID
        let vc = DetailViewController()
        vc.urlString = url
        vc.naviTitle.text = StringHelper.removepHTMLTags(from: productTitle)
        vc.isLiked = currentLiked
        vc.productID = productID
        LDTransition(viewController: vc, style: .push)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        //페이지네이션
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
    
    //실시간 검색
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        restartButton()
        if searchText == String().emptyStrng {
            shoppingList = nil
        } else {
            guard let query = searchBar.text else { return }
            callrequest(query: query, sortType: currentSortType, page: 1)
        }
    }
    
    //취소 버튼 클릭
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.shoppingList = nil
        resetButton()
    }
    
    //편집 종료 시 API 호출 방지
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        return
    }
    
    //검색 버튼 클릭
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        callrequest(query: query, sortType: currentSortType, page: 1)
    }
}

