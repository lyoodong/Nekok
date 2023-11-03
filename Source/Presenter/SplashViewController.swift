//
//  Splash.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/11/03.
//

import UIKit

import SnapKit
import Lottie

class SplashViewController: BaseViewController {
    
    let appTitle: UILabel = {
        let view = UILabel()
        view.text = "NeKoK"
        view.textColor = .nGreen
        view.font = .systemFont(ofSize: 32, weight: .heavy)
        
        return view
    }()

    let splashAnimation = LottieAnimation.named("LikeAnimation")
    
    lazy var splashAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(animation: splashAnimation)
        view.loopMode = .loop
        
        return view
    }()
    
    
    override func viewSet() {
        self.view.backgroundColor = .bgGrey
        view.addSubview(appTitle)
        view.addSubview(splashAnimationView)
        splashAnimationView.play()
        disappearView()
    }
    
    func disappearView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let vc = TabBarViewController()
            self.transitionView(viewController: vc, style: .presentFull)
        }
    }
    
    override func constraints() {
        appTitle.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        splashAnimationView.snp.makeConstraints {
            $0.bottom.equalTo(appTitle.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        }
    }
}
