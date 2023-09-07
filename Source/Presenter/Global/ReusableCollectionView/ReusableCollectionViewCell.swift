//
//  ReusableCollectionViewCell.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit

class ReusableCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Porperty
    var isLiked:Bool = false
    
    //MARK: - UI property
    lazy var productImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        return view
    }()
    
    lazy var productMallName:UILabel =  {
        let view = UILabel()
        view.textColor = .systemGray
        view.numberOfLines = 1
        
        return view
    }()
    
    lazy var productTitle:UILabel = {
        let view = UILabel()
        view.textColor = .systemGray
        view.numberOfLines = 2
        
        return view
    }()
    
    lazy var productLprice:UILabel =  {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 1
        
        return view
    }()
    
    lazy var productLikeButton:UIButton =  {
        let view = UIButton()
        let unClickedimage = UIImage(systemName: "heart")
        let clickedimage = UIImage(systemName: "heart.fill")
        view.tintColor = .black
        view.backgroundColor = .white
        view.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        view.setImage(unClickedimage, for: .normal)
        view.setImage(clickedimage, for: .selected)
        view.layer.cornerRadius = Constant.spacing / 2
        
        return view
    }()
    
    //MARK: - Define method
    override func viewSet() {
        [productImageView, productMallName, productTitle, productLprice, productLikeButton].forEach(addSubview)
    }
    
    @objc func likeButtonClicked() {
        isLiked.toggle()
    }
    
    override func constraints() {
        productImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(self)
            $0.height.equalTo(self.bounds.width)
        }
        
        productMallName.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom)
            $0.leading.equalTo(self)
        }
        
        productTitle.snp.makeConstraints {
            $0.top.equalTo(productMallName.snp.bottom)
            $0.leading.equalTo(self)
        }
        
        productLprice.snp.makeConstraints {
            $0.top.equalTo(productTitle.snp.bottom)
            $0.leading.equalTo(self)
        }
        
        productLikeButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(productImageView).inset(Constant.spacing / 2)
//            $0.trailing.equalTo(productImageView.snp.trailing).inset(Constant.spacing / 2)
            $0.size.equalTo(Constant.spacing * 2)
        }
    }
}
