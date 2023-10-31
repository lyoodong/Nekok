//
//  BaseViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSet()
        constraints()
    }

    func viewSet() {
        view.backgroundColor = .bgGrey
    }

    func constraints() {
        
    }

}
