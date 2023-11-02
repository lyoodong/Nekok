
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

> 적용한 CS 지식
> 
- 운영체제: ****Swift Concurrency****를 통한 동시성 처리

---

> 서비스
> 
- **최소 버전**: iOS 13.0
- **개발 인원**: 1인
- **개발 기간** : 2023.09.07 ~ 2022.09.16

---

> 트러블 슈팅
> 
1. 네트워크 통신을 통해 이미지 처리 시 메모리 과부화 문제

**Issue**

- 쇼핑 API를 통해 수신한 이미지 원본을 Cell에 할당할 경우, 이미지가 제대로 로드되지 않거나 런타임 에러 발생

**Solution**

- Kingfisher에서 제공하는 이미지 **캐싱**과 **다운샘플링**을 활용해 메모리 최적화
- Kingfisher는 이미지 다운로드 후에 이미지를 디스크 캐시에 저장하여 네트워크 요청을 줄이고 이미지 로딩 속도를 향상
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

Task {
                do {
                    let result = try await callRequest(query: query, sortType: currentSortType, page: 1)
                    completionHandler(result)
                } catch {
                    print("===네트워크 오류 메시지===", error)
                }
            }
```

1. 네트워크 호출 시 도착 순서 보장(동시성 문제)

**Issue**

- 네트워크 호출 순서와 도착 순서가 일치하지 않는 문제
- 즉, 검색한 순서에 따라 결과를 **동기화(synchronization)**시켜줄 필요가 있음

**Solution**

- 1. 요청 대기열을 통한 동기화 시도
→ Race condition 문제 발생
- 2.DispatchSemaphore를 통해 동기화 시도
→ Dead Lock 문제 발생
- **[최종 해결]** Swift Concurrency를 통한 동기화

**Result**

- 요청 대기열과 GCD를 사용할 때 발생하는 문제를 미연에 방지
- 쓰레드 컨텍스트 스위치를 최소화해 성능 최적화
- 테스크 내부의 비동기 코드의 실행과 일시 중지를

```swift
Task {
    do {
        let result = try await callRequest(query: query, sortType: currentSortType, page: 1)
        completionHandler(result)
    } catch {
        print("===네트워크 오류 메시지===", error)
    }
}
```

---

> 회고
> 

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
