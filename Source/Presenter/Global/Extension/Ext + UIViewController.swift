//
//  Ext + UIViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit

//ReusableIDF
extension UIViewController: ReusableIDF {
    static var IDF: String {
        return String(describing: self)
    }
}

//transition
extension UIViewController {
    
    enum TransitionStyle {
        case present
        case presentNavigation
        case push
    }
    
    func LDTransition (viewController: UIViewController, style: TransitionStyle, modalPresentationStyle: UIModalPresentationStyle = .automatic) {
        let vc = viewController
        
        switch style {
        case .present:
            present(vc, animated: true)
            
        case .presentNavigation:
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = modalPresentationStyle
            present(nav, animated: true)
        
        case .push:
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
