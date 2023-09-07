//
//  SearchViewController.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        APIManager.shared.callRequest(query: "캠핑", sortType: .sim) { Result in
            print(Result)
        }
        
    }

}
