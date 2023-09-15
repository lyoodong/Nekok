//
//  ReusableCollectionViewCell.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import RealmSwift

class ReusableCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Property
    var result:Item?
    let repo = LDRealm()
    
    //MARK: - UI property
    
    //상품 이미지
    lazy var productImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        return view
    }()
    
    //상품 판매처
    lazy var productMallName:UILabel =  {
        let view = UILabel()
        view.textColor = .systemGray
        view.numberOfLines = 1
        view.font = UIFont.regular12
        
        return view
    }()
    
    //상품 품명
    lazy var productTitle:UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 2
        view.font = UIFont.regular14
        
        return view
    }()
    
    //상품 가격
    lazy var productLprice:UILabel =  {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 1
        view.font = UIFont.bold16
        
        return view
    }()
    
    //좋아요 버튼
    lazy var productLikeButton:UIButton =  {
        let view = UIButton()
        let unselectedimage = UIImage(systemName: "heart")
        let selectedimage = UIImage(systemName: "heart.fill")
        view.setImage(unselectedimage, for: .normal)
        view.setImage(selectedimage, for: .selected)
        view.tintColor = .black
        view.backgroundColor = .white
        view.layer.cornerRadius = Constant.spacing
        view.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        return view
    }()
    
    //MARK: - Define method
    
    //addsubview
    override func viewSet() {
        [productImageView, productMallName, productTitle, productLprice, productLikeButton].forEach(addSubview)
    }
    
    //cell 재사용시 이미지 미리 제거
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
    }
    
    //좋아요 버튼 이미지 변경
    func setProductLikeButtonImage(_ isLiked:Bool) {
        ConvertData.shared.likeImageSet(productLikeButton, isLiked)
    }
    
    //선택한 아이템에 대한 값 전달
    func shoppingList(item:Item) {
        result = item
    }
    
    //좋아요 버튼 클릭
    @objc func likeButtonClicked() {
        productLikeButton.isSelected.toggle()
        
        //버튼 클릭 시 realDB에 추가 반대로 클릭 해제 시 realmDB에서 삭제
        if let result = result {
            if productLikeButton.isSelected == true {
                let task = RealmModel(title: result.title, link: result.link, image: result.image, lprice: result.lprice, mallName: result.mallName, productID: result.productID)
                repo.write(object: task, writetype: .add)
                print(repo.getRealmLocation())
            } else if productLikeButton.isSelected == false {
                let deleteObeject = repo.searchDeleteObject(key: result.productID)
                repo.delete(object: deleteObeject)
            }
        }
    }
    
    //레이아웃 설정
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
