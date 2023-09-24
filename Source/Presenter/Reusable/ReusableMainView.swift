//
//  SearchView.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import SnapKit

class ReusableMainView: BaseView {
    //MARK: - Porperty
    
    //MARK: - UI property
    
    //정렬 버튼 정확도순
    lazy var accuracyButton: sortedButton = {
        let view = sortedButton()
        view.setTitle("  정확도순  ", for: .normal)
        view.setTitleColor(.gray, for: .normal)
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.titleLabel?.font = UIFont.basicFont
        view.sortType = .sim
        
        return view
    }()
    
    //정렬 버튼 날짜순
    lazy var dateButton: sortedButton = {
        let view = sortedButton()
        view.setTitle("  날짜순  ", for: .normal)
        view.setTitleColor(.gray, for: .normal)
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.titleLabel?.font = UIFont.basicFont
        view.sortType = .date
        
        return view
    }()

    //정렬 버튼 가격 낮은 순
    lazy var priceLowButton: sortedButton = {
        let view = sortedButton()
        view.setTitle("  가격 낮은순  ", for: .normal)
        view.setTitleColor(.gray, for: .normal)
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.titleLabel?.font = UIFont.basicFont
        view.sortType = .dsc
        
        return view
    }()
    
    //정렬 버튼 가격 높은 순
    lazy var priceHighButton: sortedButton = {
        let view = sortedButton()
        view.setTitle("  가격 높은순  ", for: .normal)
        view.setTitleColor(.gray, for: .normal)
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.titleLabel?.font = UIFont.basicFont
        view.sortType = .asc
        
        return view
    }()
    
    //네트워크 진행상태를 알려주는 UIProgressView
    lazy var progressBar: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = .systemPink
        view.trackTintColor = .black
        view.progress = 0
        
        return view
    }()
    
    // 컬렉션 뷰
    lazy var searchCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: searchCollectionViewwLayout())
        view.register(ReusableCollectionViewCell.self, forCellWithReuseIdentifier: ReusableCollectionViewCell.IDF)
        view.backgroundColor = .black
        
        return view
    }()

    //MARK: - Define method
    
    override func viewSet() {
        [accuracyButton, dateButton, priceLowButton, priceHighButton, searchCollectionView, progressBar].forEach(addSubview)
    }
    
    // 컬렉션 뷰 설정
    func searchCollectionViewwLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constant.spacing / 2
        layout.minimumInteritemSpacing =  Constant.spacing / 2
        let width = UIScreen.main.bounds.width - Constant.spacing * 2
        let height = width / 2 * 1.45
        layout.itemSize = CGSize(width: width / 2, height: height)
        return layout
    }
    
    //레이아웃 설정
    override func constraints() {
        
        accuracyButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.equalTo(self.safeAreaLayoutGuide).offset(Constant.spacing)
        }
        
        dateButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.equalTo(accuracyButton.snp.trailing).offset(Constant.spacing / 2)
        }
        
        priceHighButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.equalTo(dateButton.snp.trailing).offset(Constant.spacing / 2)
        }
        
        priceLowButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.equalTo(priceHighButton.snp.trailing).offset(Constant.spacing / 2)
        }
        
        progressBar.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(accuracyButton.snp.bottom).offset(Constant.spacing / 2)
        }
        
        searchCollectionView.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(Constant.spacing)
            $0.leading.equalTo(self.safeAreaLayoutGuide).offset(Constant.spacing / 2)
            $0.trailing.equalTo(self.safeAreaLayoutGuide).inset(Constant.spacing / 2)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}
