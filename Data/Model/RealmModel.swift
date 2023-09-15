//
//  RealmModel.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/10.
//

import Foundation
import RealmSwift

class RealmModel: Object {
    @Persisted (primaryKey: true)var productID: String //기본키
    @Persisted var title: String
    @Persisted var link: String
    @Persisted var image: String
    @Persisted var lprice: String
    @Persisted var mallName: String
    @Persisted var registeredDate: Date
    @Persisted var isLiked: Bool
    
    convenience init(title: String, link: String, image: String, lprice: String, mallName: String, productID: String ) {
        self.init()
        self.title = title
        self.link = link
        self.image = image
        self.lprice = lprice
        self.mallName = mallName
        self.productID = productID
        self.registeredDate = Date()
        self.isLiked = true
    }
}
