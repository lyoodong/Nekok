//
//  ReusableCollectionViewCell.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import RealmSwift

class ReusableCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Porperty
    var isLiked:Bool = false
    var result:Item?
    
    //MARK: - UI property
    lazy var productImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        return view
    }()
    
    lazy var productMallName:UILabel =  {
        let view = UILabel()
        view.textColor = .systemGray
        view.numberOfLines = 1
        view.font = UIFont.productMall
        
        return view
    }()
    
    lazy var productTitle:UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 2
        view.font = UIFont.productTitle
        
        return view
    }()
    
    lazy var productLprice:UILabel =  {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 1
        view.font = UIFont.productPrice
        
        return view
    }()
    
    lazy var productLikeButton:UIButton =  {
        let view = UIButton()
        let unselectedimage = UIImage(systemName: "heart")
        let selectedimage = UIImage(systemName: "heart.fill")
        view.tintColor = .black
        view.backgroundColor = .white
        view.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        view.setImage(unselectedimage, for: .normal)
        view.setImage(selectedimage, for: .selected)
        view.layer.cornerRadius = Constant.spacing
        return view
    }()
    
    let repo = LDRealm()
    
    //MARK: - Define method
    override func viewSet() {
        [productImageView, productMallName, productTitle, productLprice, productLikeButton].forEach(addSubview)
    }
    
    func shoppingList(item:Item) {
        result = item
    }
    
    @objc func likeButtonClicked() {
        productLikeButton.isSelected.toggle()
        
        if let result = result {
            if productLikeButton.isSelected {
                let task = RealmModel(title: result.title, link: result.link, image: result.image, lprice: result.lprice, mallName: result.mallName, productID: result.productID)
                repo.write(object: task, writetype: .add)
                repo.getRealmLocation()
            } else {
                let deleteObeject = repo.searchDeleteObject(key: result.productID)
                repo.delete(object: deleteObeject)
            }
        }
    }
    
    override func constraints() {
        productImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(self)
            $0.height.equalTo(self.bounds.width)
        }
        
        productMallName.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(Constant.spacing / 2)
            $0.horizontalEdges.equalTo(self)
        }
        
        productTitle.snp.makeConstraints {
            $0.top.equalTo(productMallName.snp.bottom)
            $0.horizontalEdges.equalTo(self)
        }
        
        productLprice.snp.makeConstraints {
            $0.top.equalTo(productTitle.snp.bottom)
            $0.horizontalEdges.equalTo(self)
        }
        
        productLikeButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(productImageView).inset(Constant.spacing / 2)
            $0.size.equalTo(Constant.spacing * 2)
        }
    }
}
