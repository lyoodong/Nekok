//
//  RemoveHTMLTags.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/08.
//

import Foundation

enum commaSeparatorError: Int, Error {
    case failToConvertInt
    case failToFormat
}

class StringHelper {
    
    //HTMLTags제거하는 함수
    static func removepHTMLTags(from htmlString: String) -> String {
        let htmlTagPattern = "<[^>]+>"
        let regex = try! NSRegularExpression(pattern: htmlTagPattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: htmlString.utf16.count)
        var strippedString = regex.stringByReplacingMatches(in: htmlString, options: [], range: range, withTemplate: "")
        
        strippedString = strippedString.replacingOccurrences(of: "&amp;", with: "&")
        strippedString = strippedString.replacingOccurrences(of: "&lt;", with: "<")
        strippedString = strippedString.replacingOccurrences(of: "&gt;", with: ">")
        strippedString = strippedString.replacingOccurrences(of: "&nbsp;", with: " ")
        strippedString = strippedString.replacingOccurrences(of: "&quot;", with: "\"")
        
        return strippedString
    }

    
    //금액에 콤마 삽입
    static func commaSeparator(price:String) throws -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        guard let intPrice = Int(price) else {
            throw commaSeparatorError.failToConvertInt
        }
        
        guard let formattedPrice = formatter.string(from: intPrice as NSNumber) else {
            throw commaSeparatorError.failToConvertInt
        }
        
        return formattedPrice + " 원"
    }
}
