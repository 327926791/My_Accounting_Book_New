//
//  Transaction.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/11/26.
//  Copyright © 2018年 Team_927. All rights reserved.
//

import Foundation
import RealmSwift

// Transaction types
let EXPENSE = true
let INCOME = false

// Accounts
var accounts: [String] = ["Cash", "Debit Card", "Credit Card"]

// Categories
var categories: [String] = ["Food and Drink", "Apparel", "Dwelling", "Transportation", "Travelling", "Entertainment", "Health and Fitness", "Education", "Grocery", "Gift"]

class Transaction: Object {
    @objc dynamic var id : Int = 0
    @objc dynamic var type : Bool = EXPENSE
    @objc dynamic var amount : Double = 0
    @objc dynamic var account : String?
    @objc dynamic var category : String?
    @objc dynamic var location : String?
    @objc dynamic var dt : String? // Date
    @objc dynamic var text : String? // Text description
    @objc dynamic var image1 : String?
    @objc dynamic var image2 : String?
    @objc dynamic var image3 : String?
}
