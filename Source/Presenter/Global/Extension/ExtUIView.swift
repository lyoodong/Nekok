//
//  Ext + UIView.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit

extension UIView: ReusableIDF {
    
    //ReusableIDF
    static var IDF: String {
        return String(describing: self)
    }
    
    //default shadow
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}





