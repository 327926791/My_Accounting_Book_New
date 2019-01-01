//
//  MyExtensions.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/11/26.
//  Copyright © 2018年 Team_927. All rights reserved.
//

import Foundation
import UIKit
import Dropper
import RealmSwift

extension Character {
    var isAscii: Bool {
        return unicodeScalars.first?.isASCII == true
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension StringProtocol {
    var ascii: [UInt32] {
        return compactMap { $0.ascii }
    }
}

extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
    
}

// Convert UIImageOrientation to CGImageOrientation for use in Vision analysis.
extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}

extension CGRect {
    func scaleUp(scaleUp: CGFloat) -> CGRect {
        let biggerRect = self.insetBy(
            dx: -self.size.width * scaleUp,
            dy: -self.size.height * scaleUp
        )
        
        return biggerRect
    }
}

extension ViewController: DropperDelegate {
    func DropperSelectedRow(path: NSIndexPath, contents: String) {
        self.button_CreateEntry_Account.setTitle(contents, for: .normal)
    }
}

// Random variables
public extension Int {
    
    /// Returns a random Int point number between 0 and Int.max.
    public static var random: Int {
        return Int.random(n: Int.max)
    }
    
    /// Random integer between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random Int point number between 0 and n max
    public static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    ///  Random integer between min and max
    ///
    /// - Parameters:
    ///   - min:    Interval minimun
    ///   - max:    Interval max
    /// - Returns:  Returns a random Int point number between 0 and n max
    public static func random(min: Int, max: Int) -> Int {
        return Int.random(n: max - min + 1) + min
        
    }
}

public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}

public extension CGFloat {
    
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}

class RandomEntries {
    private static var foodAmount: [String: [Double]] = [:]
    private static func InitializeFoodAmount() {
        foodAmount["Tim Hortons"] = [3.49, 5.79, 9.99, 14.29]
        foodAmount["Starbucks"] = [7.99, 14.29, 19.39]
        foodAmount["McDonald's"] = [7.69, 1]
    }
    
    
    
    private static let EXPENSE = true
    private static let INCOME = false
    private static var accounts: [String] = ["Cash", "Debit Card", "Credit Card"]
    private static var categories: [String] = ["Food and Drink", "Apparel", "Dwelling", "Transportation", "Travelling", "Entertainment", "Health and Fitness", "Education", "Grocery", "Loan and Mortgage", "Bill", "Gift", "Other"]
    private static var locations: [String] = []
    
    public static func GenerateRandomEntries(count: Int, realm: Realm) {
        for i in 1...count {
            let t = Transaction()
            // 5/6 probability for expenses
            let randomType = Int.random % 6
            t.type = (randomType != 0) ? EXPENSE : INCOME
            if (t.type == EXPENSE) {
                // $0-20,000
                t.amount = Double(Int.random) + Double.random
                t.account = accounts[Int.random % accounts.count]
                t.category = categories[Int.random % categories.count]
                t.location = locations[Int.random % locations.count]
            }
            else {
                // $8,000-20,000
                t.account = "Debit Card"
                t.category = nil
                t.location = nil
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            t.dt = formatter.string(from: GenerateRandomDate(daysBack: 365)!)
            t.text = nil
            
            do {
                try
                    realm.write {
                        realm.add(t)
                }
            }
            catch {
            }
        }
    }
    
    private static func GenerateRandomDate(daysBack: Int) -> Date? {
        let day = arc4random_uniform(UInt32(daysBack)) + 1
        let hour = arc4random_uniform(23)
        let minute = arc4random_uniform(59)
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = -Int(day - 1)
        offsetComponents.hour = Int(hour)
        offsetComponents.minute = Int(minute)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0))
        return randomDate
    }
    
    private static func GenerateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
        return String((0...(length - 1) ).map{ _ in letters.randomElement()! })
    }
    
    // $0-20
    // $20-50
    // $50-100
    // $100-500
    // $500-2000
    // $2000-5000
    // $5000-10000
    // $10000-20000
    public static func WeightedRandom() -> Int {
        let weights = [262144, 65536, 32768, 16384, 4096, 512, 32, 1]
        var ranges = [Int]()
        var sum = 0
        for weight in weights {
            sum += weight
            ranges.append(sum)
        }
        //
        let expectation = 10*weights[0]/sum+25*weights[1]/sum+75*weights[2]/sum+300*weights[3]/sum+1250*weights[4]/sum+3500*weights[5]/sum+7500*weights[6]/sum+15000*weights[7]/sum
        print(expectation)
        let rand = Int.random(min: 1, max: sum)
        var index = 0
        for range in ranges {
            if rand <= range {
                return index
            }
            index += 1
        }
        return index - 1
    }
}
