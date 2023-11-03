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
import RxSwift
import RxCocoa

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
        view.textColor = .black
        return view
    }()
    
    var likedProductID: [String] = []
    
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
        
        guard let likedShoppingList else { return }
        likedProductID = likedShoppingList.map { $0.productID }
    }
    
    override func viewSet() {
        super.viewSet()
        navigationbarSet()
        searchControllerSet()
        searchCollectionViewSet()
        addtarget()
        bind()
    }
    
    lazy var realTimeSearchBar = searchController.searchBar.rx.text.orEmpty
    let disposeBag = DisposeBag()
    
    func bind() {
        realTimeSearchBar
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                owner.restartButton()
                if value.isEmpty {
                    owner.shoppingList = nil
                    owner.resetButton()
                } else {
                    owner.shoppingList = nil
                    owner.changeButtonUI()
                    owner.searchView.accuracyButton.isSelected.toggle()
                    owner.callrequest(query: value, sortType: owner.currentSortType, page: 1)
                }
            }
            .disposed(by: disposeBag)
    }
    
    //검색 API 호출
    func callrequest(query:String, sortType: SortType, page:Int) {
        APIManager.shared.callRequest(query: query, sortType: sortType, page: page) { [weak self] Result in
            if self?.shoppingList == nil {
                self?.shoppingList = Result
            } else {
                self?.shoppingList?.items.append(contentsOf: Result.items)
            }
        } progressHandler: { progress in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1) {
                    let result = Float(progress)
                    self.setProgress(result, animated: true)
                }
            }
        }
    }
    
    func callRequest(query:String, sortType: SortType, page:Int) async {
        var result: Result?
        
        do {
            result = try await APIManager.shared.callrequest(query: query, sortType: sortType, page: page)
            shoppingList = result
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    //progressBar 상태
    func setProgress(_ progress: Float, animated: Bool) {
        searchView.progressBar.progress = progress
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
        searchController.searchBar.tintColor = .nGreen
        searchController.searchBar.barStyle = .default
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
            button.setTitleColor(isSelected ? .white : .black, for: .normal)
            button.backgroundColor = isSelected ? .nGreen : .white
        }
    }
    
    //버튼 비활성화
    func resetButton() {
        buttons.forEach {
            $0.isSelected = false
            $0.setTitleColor( .black, for: .normal)
            $0.backgroundColor = .white
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
        vc.title = StringHelper.removepHTMLTags(from: productTitle)
        vc.selectedData = shoppingList.items[indexPath.row]
        transitionView(viewController: vc, style: .push)
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


