//
//  APIManager.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/07.
//

import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()
    private init() { }

    func callRequest(query: String, sortType: SortType, page: Int, complitionHandler: @escaping (Result) ->Void) {
        
        guard let encodeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        let url = "https://openapi.naver.com/v1/search/shop.json?query=\(encodeQuery)&display=30&start=\(page)&sort=\(sortType)"
        let headers:HTTPHeaders = [
            "X-Naver-Client-Id":APIkey.clientID,
            "X-Naver-Client-Secret":APIkey.clientSecret
        ]
        
        print(url)
        AF.request(url, headers: headers).validate().responseDecodable(of: Result.self){ response in
        
            switch response.result {
            case .success(let value):
                print("APIManager request 성공")
                print(query)
                complitionHandler(value)
        
            case .failure(let error):
                print("APIManager request 실패")
                print("===오류 메시지===", error)
            }
        }
    }
}
