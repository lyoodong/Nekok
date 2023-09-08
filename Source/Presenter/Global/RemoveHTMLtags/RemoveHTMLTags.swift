//
//  RemoveHTMLTags.swift
//  SecondRecap
//
//  Created by Dongwan Ryoo on 2023/09/08.
//

import Foundation

class RemoveHTMLTags {
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
}
