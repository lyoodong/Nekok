//
//  Model.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import Foundation

// MARK: - Result
struct Result: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    var items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let title: String
    let link: String
    let image: String
    let lprice: String
    let mallName: String
    let productID: String
    var isLiked:Bool = false

    enum CodingKeys: String, CodingKey {
        case title, link, image, lprice, mallName
        case productID = "productId"
    }
}

