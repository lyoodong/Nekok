//
//  ConvertModel.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/12.
//

import UIKit

class ConvertData {

    static let shared = ConvertData()
    private init() { }
    
    //RealmModel -> Item
    func toCodableModel(_ realmModel: RealmModel) -> Item {
        let item = Item(title: realmModel.title,
                        link: realmModel.link,
                        image: realmModel.image,
                        lprice: realmModel.lprice,
                        mallName: realmModel.mallName,
                        productID: realmModel.productID,
                        isLiked: realmModel.isLiked)
        return item
    }
    
    //Item -> RealmModel
    func toRealmModel(_ item: Item) -> RealmModel {
        let realmModel = RealmModel()
        realmModel.title = item.title
        realmModel.link = item.link
        realmModel.image = item.image
        realmModel.lprice = item.lprice
        realmModel.mallName = item.mallName
        realmModel.productID = item.productID
        realmModel.isLiked = item.isLiked
        return realmModel
    }
    
    let repo = LDRealm()
    
    //현재 좋아요 상태
    //-> 단순하게 값을 반환하는 역할인데 굳이 callback 패턴을 사용할 이유가 없지 않을까?
    //callback의 정의 1. 다른 함수의 인자로 상용되는 함수, 2. 어떤 이벤트에 의해 호출되는 함수
    //하지만 이번 RECAP에서 해당 함수는 특정 이벤트에 의해 호출되는 것이 아니라, 단순히 값을 전달하는 역할을 가진다.
    //따라서, 굳이?
    func currentLikeStatus(productID:String ) -> Bool {
        let item = repo.readByPrimaryKey(object: RealmModel.self, productID: productID)
        return item.isLiked
    }
    
    //현재 좋아요 상태에 따른 버튼 이미지
    func likeImageSet(_ button: UIButton, _ isLiked: Bool) {
        button.isSelected = isLiked
        let unselectedimage = UIImage(systemName: "heart")
        let selectedimage = UIImage(systemName: "heart.fill")
        
        if button.isSelected {
            button.setImage(selectedimage, for: .selected)
        } else {
            button.setImage(unselectedimage, for: .normal)
        }
    }
    
    //현재 좋아요 상태에 따른 버튼 이미지
    func likeImageSet(_ button: UIBarButtonItem, isLiked: Bool) {
        if isLiked {
            button.image = UIImage(systemName: "heart.fill")?.withTintColor(.white)
        } else {
            button.image = UIImage(systemName: "heart")
        }
    }
    
    //현재 좋아요 상태에 따른 Realm 삭제 or 추가
    func changeButtonStatus(object: RealmModel, key:String, isLiked: Bool) {
        switch isLiked {
        case true:
            repo.write(object: object, writetype: .add)
        case false:
            let item = repo.searchDeleteObject(key: key)
            repo.delete(object: item)
        }
    }
}
