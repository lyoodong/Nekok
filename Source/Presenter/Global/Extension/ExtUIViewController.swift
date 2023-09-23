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

//alert
extension UIViewController {

    func LDAlert(alertCase: AlertType, title: String?, message: String?, preferredStyle: UIAlertController.Style , firstTitle:String?, firsthandler: ((UIAlertAction) -> Void)?, secondTitle: String?, secondhandler: ((UIAlertAction) -> Void)? ) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        let firstAction = UIAlertAction(title: firstTitle, style: .default, handler: firsthandler)
        let secondAction = UIAlertAction(title: secondTitle, style: .default, handler: secondhandler)
        let cancel = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(cancel)
        
        switch alertCase {
        case .oneway:
             return alert
        case .twoway:
            alert.addAction(firstAction)
            return alert
        case .threeway:
            alert.addAction(firstAction)
            alert.addAction(secondAction)
            return alert

        }
    }

}
