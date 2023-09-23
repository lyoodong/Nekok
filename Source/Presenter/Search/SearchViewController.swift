//
//  SearchViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import Alamofire
import Kingfisher
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
    
    //검색 타입, 기본 정확도 순
    var currentSortType:SortType = .sim
    
    //Realm에서, 좋아요 클릭한 상품 데이터 저장
    var likedShoppingList:Results<RealmModel>? {
        didSet {
            searchView.searchCollectionView.reloadData()
        }
    }
    
    //현재 상품의 좋아요 상태
    var isLiked:Bool = false
    
    //Realm Repository
    var repo = LDRealm()
    
    //MARK: - UI property
    
    //메인뷰
    let searchView = ReusableMainView()
    
    //seerchBar를 넣을 UISearchController
    let searchController = UISearchController()
    
    //전체 버튼 관리를 위한 배열
    lazy var buttons: [sortedButton] = [searchView.accuracyButton, searchView.dateButton, searchView.priceHighButton, searchView.priceLowButton]
    
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
    
    //화면 전환 시 realmDB 데이터 불러오기
    override func viewWillAppear(_ animated: Bool) {
        callRealmDB()
    }
    
    //Realm의 데이터를 likedShoppingList에 저장
    func callRealmDB() {
        likedShoppingList = repo.read(object: RealmModel.self, readtype: .read, bykeyPath: nil)
    }
    
    override func viewSet() {
        navigationbarSet()
        searchControllerSet()
        searchCollectionViewSet()
        addtarget()
    }
    
    //검색 API 호출
    func callrequest(query:String, sortType: SortType, page:Int) {
        
        APIManager.shared.callRequest(query: query, sortType: sortType, page: page) { [weak self] Result in
            if self?.shoppingList == nil {
                self?.shoppingList = Result
            } else {
                self?.shoppingList?.items.append(contentsOf: Result.items)
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
    
    //타겟 설정
    func addtarget() {
        searchView.accuracyButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        searchView.dateButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        searchView.priceHighButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        searchView.priceLowButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
    }
    
    //정렬 버튼 클릭 시 매서드
    @objc func buttonClicked(_ sender: sortedButton) {
        
        if searchBarText() == "" {
            let alert = LDAlert(alertCase: .oneway, title: "검색어를 입력해주세요", message: nil, preferredStyle: .alert, firstTitle: "", firsthandler: nil, secondTitle: "", secondhandler: nil)
            resetButton()
            present(alert, animated: true)
        } else {
            if let sortType = sender.sortType {
                handleSortType(sortType)
            }
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
        
        //검색어가 빈공백으로 이루어진 경우를 대비
        let removeSpaceString = searchBarText().trimmingCharacters(in: .whitespacesAndNewlines)
        let searchBarIsEmpty = removeSpaceString.isEmpty
        
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
        buttons.forEach {
            $0.isSelected = false
            $0.setTitleColor( .gray, for: .normal)
            $0.backgroundColor = .black
        }
    }
    
    
    //버튼 활성화
    func restartButton() {
        buttons.forEach {
            $0.isEnabled = true
        }
    }
    
    //서치바에서 현재 검색하고 있는 텍스트
    func searchBarText() -> String {
        guard let searchText = searchController.searchBar.text else { return ""}
        let result = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
}

//MARK: - Extension
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    //셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoppingList?.items.count ?? 0
    }
    
    //셀 등록
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCollectionViewCell.IDF, for: indexPath) as? ReusableCollectionViewCell else { return UICollectionViewCell() }
        
        cell.repo = repo
        
        guard let shoppingList = shoppingList else { return UICollectionViewCell() }
        
        let title = shoppingList.items[indexPath.row].title
        //HTML 테그 제거
        let productTitle = StringHelper.removepHTMLTags(from: title)
        
        let price = shoppingList.items[indexPath.row].lprice
        //콤마 추가
        var lprice = ""
        
        do {
            try lprice = StringHelper.commaSeparator(price: price)
        } catch {
            switch error {
            case commaSeparatorError.failToConvertInt:
                print("금액이 숫자가 아닙니다.")
            case commaSeparatorError.failToFormat:
                print("포맷팅에 실패했습니다.")
            default:
                print("알 수 없는 에러")
            }
            lprice = "금액이 숫자가 아닙니다."
        }
        
        let productID = shoppingList.items[indexPath.row].productID
        
        //shoppingList 데이터 할당
        cell.productTitle.text = productTitle
        cell.productMallName.text = "[ \(shoppingList.items[indexPath.row].mallName) ]"
        cell.productLprice.text = lprice
        
        //이미지 처리
        DispatchQueue.global().async {
            let imageLink = self.shoppingList?.items[indexPath.row].image ?? ""
            if let url = URL(string: imageLink) {
                DispatchQueue.main.async {
                    cell.productImageView.kf.setImage(
                        with: url,
                        placeholder: UIImage(named: "noImage"),
                        options:[
                            .cacheOriginalImage,
                            .transition(.fade(1)),
                            .processor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))),
                            .scaleFactor(UIScreen.main.scale)
                    ])
                }
            }
        }
        
        //등록된 좋아요 물품 필터 로직
        guard let likedShoppingList else { return UICollectionViewCell() }
        //좋아요 클릭된 상품의 productID
        lazy var likedProductID = likedShoppingList.map { $0.productID }
        
        if likedProductID.contains(productID) {
            cell.productLikeButton.isSelected = true
        } else {
            cell.productLikeButton.isSelected = false
        }
        
        let result = shoppingList.items[indexPath.row]
        cell.shoppingList(item: result)
        
        return cell
    }
    
    //샐 클릭
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let shoppingList = shoppingList else { return }
        
        let productID = shoppingList.items[indexPath.row].productID
        let productTitle = shoppingList.items[indexPath.row].title
        
        let url = "https://msearch.shopping.naver.com/product/" + productID
        
        let vc = DetailViewController()
        vc.urlString = url
        vc.naviTitle.text = StringHelper.removepHTMLTags(from: productTitle)
        vc.selectedData = shoppingList.items[indexPath.row]
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
        let text = searchText.trimmingCharacters(in: .whitespaces)
        if text.isEmpty {
            shoppingList = nil
            resetButton()
        } else {
            shoppingList = nil
            searchView.accuracyButton.isSelected.toggle()
            changeButtonUI()
            
            guard let query = searchBar.text else { return }
            callrequest(query: query, sortType: currentSortType, page: 1)
        }
    }
    
    //취소 버튼 클릭
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shoppingList = nil
        resetButton()
    }
    
    //검색 버튼 클릭
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shoppingList = nil
        guard let query = searchBar.text else { return }
        callrequest(query: query, sortType: currentSortType, page: 1)
    }
}

