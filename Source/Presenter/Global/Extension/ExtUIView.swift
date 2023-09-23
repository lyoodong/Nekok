//
//  Ext + UIView.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit

//ReusableIDF
extension UIView: ReusableIDF {
    static var IDF: String {
        return String(describing: self)
    }
}

