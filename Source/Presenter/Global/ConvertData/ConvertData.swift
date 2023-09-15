//
//  ConvertModel.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/12.
//

import Foundation
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
    func currentLikeStatus(productID:String, completion: (Bool) -> Void) {
        let item = repo.readByPrimaryKey(object: RealmModel.self, productID: productID)
        completion(item.isLiked)
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
