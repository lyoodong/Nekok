
# Nekok

> 핵심 기능
> 
- 네이버 쇼핑 API를 활용한 검색 및 페이지네이션 기능 구현
- Realm DB를 활용해 상품 좋아요 기능 구현
- Alamofire + Router 패턴을 활용해 네트워크 통신 기능 구현
- Kingfisher를 활용해 이미지 캐싱 및 다운샘플링 구현

---

> 기술 스택
> 
- **언어**: Swift
- **프레임워크**: UIkit, WebKit
- **디자인패턴**: MVC, Router
- **라이브러리**: Kingfisher, RealmSwift, Alamofire, SnapKit

---

> 서비스
> 
- **최소 버전**: iOS 13.0
- **개발 인원**: 1인
- **개발 기간** : 2023.09.07 ~ 2022.09.16

---

> 트러블 슈팅
> 
1. 이미지 **캐싱 및 다운샘플링**

**Issue**

- 쇼핑 API를 통해 수신한 이미지 원본을 Cell에 할당할 경우, 메모리 오버헤드로 이미지가 제대로 로드되지 않거나 런타임 에러 발생

**Solution**

- Kingfisher에서 제공하는 이미지 **캐싱**과 **다운샘플링**을 활용해 메모리 최적화
- 캐싱을 통해 이미지를 디스크 캐시에 저장하여 네트워크 요청을 줄이고 이미지 로딩 속도를 향상
- 다운샘플링을 통해 원본보다 낮은 해상도로 조정하여 메모리 절약

**Result**

```swift
//기존 코드
DispatchQueue.global().async {
    let imageLink = self.shoppingList?.items[indexPath.row].image ?? ""

    if let url = URL(string: imageLink){
        let data = try! Data(contentsOf: url)
        let image = UIImage(data: data)
        DispatchQueue.main.async {
            cell.productImageView.image = image   
        }
    }
}

//개선된 코드
DispatchQueue.global().async {
    let imageLink = self.shoppingList?.items[indexPath.row].image ?? ""

    if let url = URL(string: imageLink) {
        DispatchQueue.main.async {
            cell.productImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "noImage"),
								//이미지 로드 시 여러 옵션 선택 가능
                options:[
                    .cacheOriginalImage, //캐싱 처리 
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))), //이미지 다운 샘플링
                    .scaleFactor(UIScreen.main.scale) 
                ])
        }
```

1. 실시간 검색에 따른, 불필요한 API 호출 

**Issue**

- 서치바에서 실시간 검색 기능을 제공할 경우, 이용자가 원하지 않는 검색어에 대해서도 네트워크 호출 발생

**Solution**

- RxSwift를 활용해 searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) 메서드를 대체
- distinctUntilChanged() 오퍼레이터를 통해 연속된 중복 값을 필터링
- debounce() 오퍼레이터를 통해 새로운 입력이 없을 때만(즉, 검색할 키워드 입력이 완료되었을 때) 네트워크 호출

**Result**

```swift
////핵심 적인 로직을 보여드리기 위해, UI업데이트 코드는 삭제했습니다.

//기존 코드
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: .whitespaces)
        if text.isEmpty {
            shoppingList = nil
        } else {
            shoppingList = nil
            guard let query = searchBar.text else { return }
            callRequest(query: query, sortType: currentSortType, page: 1)
        }
    }

//개선된 코드

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
            } else {
                owner.shoppingList = nil
                owner.callRequest(query: value, sortType: owner.currentSortType, page: 1)
            }
        }
        .disposed(by: disposeBag)
}
```

---

> 회고
> 

**What I Learned**

- RealmSwift를 통한 로컬 DB 작업 경험
- 이미지 캐싱과 다운 샘플링

**Areas for Improvement**

- MVVM 구조 변경

이번 프로젝트에서는 Realm을 활용한 간단한 로컬 DB 구축, 페이지네이션, 실시간 검색, 오픈 API 네트워크 통신 등 실제 서비스에서 많이 사용되는 기술 들을 경험해볼 수 있었다. 

프로젝트를 진행하면서, 아쉬웠던 점은 우선 미시적인 모듈화에 너무 집착했던 점이다. 코드의 재사용성을 늘릴 수록 응집도는 높아지고, 결합도는 낮아진다는 장점이 있었으나 그 만큼 범용성이 감소한다는 단점이 있다. 이는 View나 로직의 미세한 차이에도 대응하지 못할 수 있다는 말이다. 따라서, 공통점과 차이점을 명확히 하고 적절한 모듈화 수준을 찾는 것이 필요했다. 

다음으로, MVVM 패턴으로 전환이 필요함을 느꼈다. View 파일을 만들어 ViewController에 가중되는 코드를 어느정도 이전하긴 했지만, 처리해야할 로직이 많아지면서 UI 로직과 비지니스 로직 분리가 필요해보였다. 

> 📒 커밋 메시지 형식
> 

| 유형 | 설명 | 예시 |
| --- | --- | --- |
| FIX | 버그 또는 오류 해결 | [FIX] #10 - 콜백 오류 수정 |
| ADD | 새로운 코드, 라이브러리, 뷰, 또는 액티비티 추가 | [ADD] #11 - LoginActivity 추가 |
| FEAT | 새로운 기능 구현 | [FEAT] #11 - Google 로그인 추가 |
| DEL | 불필요한 코드 삭제 | [DEL] #12 - 불필요한 패키지 삭제 |
| REMOVE | 파일 삭제 | [REMOVE] #12 - 중복 파일 삭제 |
| REFACTOR | 내부 로직은 변경하지 않고 코드 개선 (세미콜론, 줄바꿈 포함) | [REFACTOR] #15 - MVP 아키텍처를 MVVM으로 변경 |
| CHORE | 그 외의 작업 (버전 코드 수정, 패키지 구조 변경, 파일 이동 등) | [CHORE] #20 - 불필요한 패키지 삭제 |
| DESIGN | 화면 디자인 수정 | [DESIGN] #30 - iPhone 12 레이아웃 조정 |
| COMMENT | 필요한 주석 추가 또는 변경 | [COMMENT] #30 - 메인 뷰컨 주석 추가 |
| DOCS | README 또는 위키 등 문서 내용 추가 또는 변경 | [DOCS] #30 - README 내용 추가 |
| TEST | 테스트 코드 추가 | [TEST] #30 - 로그인 토큰 테스트 코드 추가 |
