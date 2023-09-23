//
//  Ext + UIButton.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/10.
//

import UIKit


//버튼에 대한 정렬 속성을 확장
//하지만, 이렇게 될 경우 정렬 버튼을 제외한 다른 버튼을 구현할 때도 해당 속성이 뜬다.
//한정적으로 사용되는 속성에 대해서는 프로토콜이나 서브클래스로 대체하는 것이 바람직해보인다.
//extension UIButton {
//    var sortType: SortType? {
//        get {
//            return SortType(rawValue: tag)
//        }
//        set {
//            if let newValue = newValue {
//                tag = newValue.rawValue
//            } else {
//                tag = 0
//            }
//        }
//    }
//}

class sortedButton: UIButton {
    
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


