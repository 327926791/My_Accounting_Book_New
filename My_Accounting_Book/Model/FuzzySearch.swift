//
//  FuzzySearch.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/11/27.
//  Copyright © 2018年 Team_927. All rights reserved.
//

import Foundation

class FuzzySearch {
    // How well b matches to a
    static func levenshteinDist(a: String, b: String) -> Int {
        var cost: Int
        
        let m = a.count
        let n = b.count
        
        let r = [Int](repeating: 0, count: n + 1)
        var d = [[Int]](repeating: r, count: m + 1)
        
        for i in 1...m {
            d[i][0] = i
        }
        
        for j in 1...n {
            d[0][j] = j
        }
        
        for j in 1...n {
            for i in 1...m {
                if a[i] == b[j] {
                    cost = 0
                }
                else {
                    cost = 1
                }
                d[i][j] = min(min(d[i-1][j] + 1, d[i][j-1] + 1),
                              d[i-1][j-1] + cost)
            }
        }
        
        return d[m][n]
    }
}
