//
//  Ext + UIButton.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/10.
//

import UIKit


extension UIButton {
    var sortType: SortType? {
        get {
            return SortType(rawValue: tag)
        }
        set {
            if let newValue = newValue {
                tag = newValue.rawValue
            } else {
                tag = 0
            }
        }
    }
}


