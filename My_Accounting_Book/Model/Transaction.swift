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
var categories: [String] = ["Food and Drink", "Apparel", "Rent", "Loan and Mortgage", "Bill", "Transportation", "Travelling", "Entertainment", "Health and Fitness", "Education", "Grocery", "Shopping", "Gift", "Online Shopping", "Other"]
var incomeCategories: [String] = ["Salary and Wage", "Business Profit", "Investment Return", "Bank Interest", "Payment Received", "Other"]

class Transaction: Object {
    @objc dynamic var id = UUID().uuidString
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
    @objc dynamic var amountStr : String = "0"
}

class TransactionTemplate: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var type : Bool = EXPENSE
    @objc dynamic var amount : Double = 0
    @objc dynamic var account : String?
    @objc dynamic var category : String?
    @objc dynamic var location : String?
    @objc dynamic var text : String? // Text description
    @objc dynamic var image1 : String?
    @objc dynamic var image2 : String?
    @objc dynamic var image3 : String?
    @objc dynamic var amountStr : String = "0"
}

class RandomEntries {
    // Food and Drink
    private var foodAmount: [String: [Double]] = [:]
    private var foodLocations: [String: [String]] = [:]
    private let lowEnd = [3.49, 5.59, 7.69, 9.79]
    private let lowMid = [7.69, 9.79, 11.29, 13.39]
    private let midEnd = [11.29, 13.39, 15.49, 17.59, 19.69]
    private let midHigh = [17.59, 19.69, 25.59, 30.69]
    private let highEnd = [25.59, 30.69, 35.79, 40.89]
    
    // Shopping
    private let shoppingLocations = ["Eaton Centre", "Yorkdale Shopping Centre", "Fairview Mall", "Yonge Eglinton Centre", "York Ville Village", "CF Shops at Don Mills", "Bayview Village Shopping Centre", "Toronto Premium Outlets"]
    
    // Grocery
    private let groceryLocations = ["Rexall", "Shoppers Drug Mart", "Metro", "No Frills", "Loblaws", "Bulk Barn", "Walmart", "T&T Supermarket"]
    
    // Health and Fitness
    private let healthLocations = ["GoodLife Fitness", "HealthOne Medical Centre", "Shoppers Pharmacy", "HK Dental Centre", "LASIK MD"]
    
    // Entertainment
    private let entertainmentLocations = ["Cineplex", "TIFF Bell Lightbox", "CAA Theatre", "Massey Hall", "B Boss Ktv", "8090 Karaoke", "Escape Zone", "Trapped!", "K1 Speed", "Smash Ping Pong Lounge", "Billiards Academy & Sports Bar"]
    
    // Constructor
    init() {
        // Food and Drink
        foodAmount["Tim Hortons"] = lowEnd
        foodAmount["Starbucks"] = lowMid
        foodAmount["Ten Ren's Tea"] = lowMid
        foodAmount["OneZo Tapioca"] = lowMid
        foodAmount["Ding Dong Pastries & Cafe"] = lowEnd
        foodAmount["McDonald's"] = lowMid
        foodAmount["KFC"] = lowMid
        foodAmount["Burger King"] = lowMid
        foodAmount["Popeyes"] = midEnd
        foodAmount["Pizaa Pizza"] = lowMid
        foodAmount["Pizza Nova"] = lowMid
        foodAmount["Subway"] = lowMid
        foodAmount["Mr. Sub"] = lowMid
        foodAmount["Taco Bell"] = midEnd
        foodAmount["Fat Bastard Burrito"] = midEnd
        foodAmount["Smoke's Poutinerie"] = midEnd
        foodAmount["Sansotei Ramen"] = midHigh
        foodAmount["Kenzo Ramen"] = midHigh
        foodAmount["Ajisen Ramen"] = midEnd
        foodAmount["Gyugyuya"] = midHigh
        foodAmount["Top Sushi"] = midEnd
        foodAmount["Spring Sushi"] = highEnd
        foodAmount["Kachi Korean Restaurant"] = midEnd
        foodAmount["Korean Grill House"] = highEnd
        foodAmount["Pho Hung"] = midEnd
        foodAmount["House of Gourmet"] = midEnd
        foodAmount["Swatow Restaurant"] = highEnd
        foodAmount["Shanghai 360"] = midEnd
        foodAmount["HeyNoodles"] = midEnd
        foodAmount["Magic Noodle"] = midHigh
        foodAmount["Lan Zhou Ramen"] = midEnd
        foodAmount["Dagu Rice Noodle"] = midEnd
        foodAmount["Mother's Dumplings"] = midEnd
        foodAmount["Little Sheep Mongolian Hot Pot"] = highEnd
        foodAmount["La Bettola Di Terroni"] = highEnd
        foodAmount["Anoush Sharwama & Falafel"]  = lowMid
        foodAmount["Tabriz Persian Cookhouse"]  = midHigh
        foodLocations["Lunch"] = ["McDonald's", "KFC", "Burger King", "Popeyes", "Pizaa Pizza", "Pizza Nova", "Subway", "Mr. Sub", "Taco Bell", "Fat Bastard Burrito", "Smoke's Poutinerie", "Sansotei Ramen", "Kenzo Ramen", "Ajisen Ramen", "Gyugyuya", "Top Sushi", "Kachi Korean Restaurant", "Pho Hung", "House of Gourmet", "Shanghai 360", "HeyNoodles", "Magic Noodle", "Lan Zhou Ramen", "Dagu Rice Noodle", "Mother's Dumplings", "Anoush Sharwama & Falafel", "Tabriz Persian Cookhouse"]
        foodLocations["Dinner"] = ["McDonald's", "KFC", "Burger King", "Popeyes", "Pizaa Pizza", "Pizza Nova", "Subway", "Mr. Sub", "Taco Bell", "Fat Bastard Burrito", "Smoke's Poutinerie", "Sansotei Ramen", "Kenzo Ramen", "Ajisen Ramen", "Gyugyuya", "Top Sushi", "Kachi Korean Restaurant", "Pho Hung", "House of Gourmet", "Shanghai 360", "HeyNoodles", "Magic Noodle", "Lan Zhou Ramen", "Dagu Rice Noodle", "Mother's Dumplings", "Anoush Sharwama & Falafel", "Tabriz Persian Cookhouse"]
        foodLocations["Special"] = ["Spring Sushi", "Korean Grill House", "Swatow Restaurant", "Little Sheep Mongolian Hot Pot", "La Bettola Di Terroni"]
        foodLocations["Cafe"] = ["Tim Hortons", "Starbucks", "Ten Ren's Tea", "OneZo Tapioca", "Ding Dong Pastries & Cafe"]
    }
    
    // After instatntiation, call this function to generate random entries
    public func GenerateRandomEntries(realm: Realm) {
        let startDate = Date.from(year: 2018, month: 1, day: 1)!
        let endDate = Date.from(year: 2018, month: 12, day: 24)!
        var date = startDate
        let calendar = Calendar.current
        let formatterDoM = DateFormatter()
        formatterDoM.dateFormat = "dd"
        let formatterDoW = DateFormatter()
        formatterDoW.dateFormat = "EEE"
        while date <= endDate {
            let dayOfMonth = formatterDoM.string(from: date)
            let dayOfWeek = formatterDoW.string(from: date)
            
            // Income and rent
            if dayOfMonth == "01" {
                // Income
                let t1 = Transaction()
                t1.type = INCOME
                t1.amount = 2500
                t1.amountStr = String(t1.amount)
                t1.account = "Debit Card"
                t1.category = "Salary and Wage"
                t1.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t1)
                    }
                }
                catch {
                }
                
                // Rent
                let t2 = Transaction()
                t2.type = EXPENSE
                t2.amount = 1200
                t2.amountStr = String(t2.amount)
                t2.account = "Cash"
                t2.category = "Rent"
                t2.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t2)
                    }
                }
                catch {
                }
            }
            
            // Income, investment return and bill
            if dayOfMonth == "15" {
                // Income
                let t1 = Transaction()
                t1.type = INCOME
                t1.amount = 2500
                t1.amountStr = String(t1.amount)
                t1.account = "Debit Card"
                t1.category = "Salary and Wage"
                t1.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t1)
                    }
                }
                catch {
                }
                
                // Investment return
                let t2 = Transaction()
                t2.type = INCOME
                t2.amount = 666
                t2.amountStr = String(t2.amount)
                t2.account = "Debit Card"
                t2.category = "Investment Return"
                t2.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t2)
                    }
                }
                catch {
                }
                
                // Bill
                let t3 = Transaction()
                t3.type = EXPENSE
                t3.amount = Double.round2(input: Double(Int.random(min: 800, max: 1000)) + Double.random)
                t3.amountStr = String(t3.amount)
                t3.account = "Debit Card"
                t3.category = "Bill"
                t3.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t3)
                    }
                }
                catch {
                }
            }
            
            // Transportation
            if dayOfWeek != "Sat" && dayOfWeek != "Sun" {
                let t1 = Transaction()
                t1.type = EXPENSE
                t1.amount = 6
                t1.amountStr = String(t1.amount)
                t1.account = "Debit Card"
                t1.category = "Transportation"
                t1.dt = Date.to(date: date)
                t1.text = "TTC"
                do {
                    try
                        realm.write {
                            realm.add(t1)
                    }
                }
                catch {
                }
            }
            else {
                let rand1 = Int.random(min: 1, max: 4)
                if rand1 == 2 {
                    let t1 = Transaction()
                    t1.type = EXPENSE
                    t1.amount = Double.round2(input: Double(Int.random(min: 20, max: 40)) + Double.random)
                    t1.amountStr = String(t1.amount)
                    t1.account = "Debit Card"
                    t1.category = "Transportation"
                    t1.dt = Date.to(date: date)
                    t1.text = "Uber"
                    do {
                        try
                            realm.write {
                                realm.add(t1)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Apparel
            if true {
                let rand1 = Int.random(min: 1, max: 30)
                if rand1 == 15 {
                    let t1 = Transaction()
                    t1.type = EXPENSE
                    t1.amount = Double.round2(input: Double(Int.random(min: 40, max: 400)) + Double.random)
                    t1.amountStr = String(t1.amount)
                    t1.account = "Credit Card"
                    t1.category = "Apparel"
                    let rand2 = Int.random(min: 0, max: shoppingLocations.count - 1)
                    t1.location = shoppingLocations[rand2]
                    t1.dt = Date.to(date: date)
                    do {
                        try
                            realm.write {
                                realm.add(t1)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Food and Drink
            if true {
                // Lunch
                let t1 = Transaction()
                t1.type = EXPENSE
                let rand1 = Int.random(min: 0, max: foodLocations["Lunch"]!.count - 1)
                let res1 = foodLocations["Lunch"]![rand1]
                let rand2 = Int.random(min: 0, max: foodAmount[res1]!.count - 1)
                t1.amount = foodAmount[res1]![rand2]
                t1.amountStr = String(t1.amount)
                t1.account = "Credit Card"
                t1.category = "Food and Drink"
                t1.location = res1
                t1.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t1)
                    }
                }
                catch {
                }
                
                // Dinner or special
                let randDS = Int.random(min: 1, max: 10)
                let t2 = Transaction()
                t2.type = EXPENSE
                // Dinner
                if randDS != 5 {
                    let rand3 = Int.random(min: 0, max: foodLocations["Dinner"]!.count - 1)
                    let res2 = foodLocations["Dinner"]![rand3]
                    let rand4 = Int.random(min: 0, max: foodAmount[res2]!.count - 1)
                    t2.amount = foodAmount[res2]![rand4]
                    t2.location = res2
                }
                    // Special
                else {
                    let rand3 = Int.random(min: 0, max: foodLocations["Special"]!.count - 1)
                    let res2 = foodLocations["Special"]![rand3]
                    let rand4 = Int.random(min: 0, max: foodAmount[res2]!.count - 1)
                    t2.amount = foodAmount[res2]![rand4]
                    t2.location = res2
                }
                t2.amountStr = String(t2.amount)
                t2.account = "Credit Card"
                t2.category = "Food and Drink"
                t2.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t2)
                    }
                }
                catch {
                }
                
                // Cafe
                let randC = Int.random(min: 1, max: 7)
                if randC == 4 {
                    let t2 = Transaction()
                    t2.type = EXPENSE
                    let rand3 = Int.random(min: 0, max: foodLocations["Cafe"]!.count - 1)
                    let res2 = foodLocations["Cafe"]![rand3]
                    let rand4 = Int.random(min: 0, max: foodAmount[res2]!.count - 1)
                    t2.amount = foodAmount[res2]![rand4]
                    t2.amountStr = String(t2.amount)
                    t2.account = "Credit Card"
                    t2.category = "Food and Drink"
                    t2.location = res2
                    t2.dt = Date.to(date: date)
                    do {
                        try
                            realm.write {
                                realm.add(t2)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Shopping
            if true {
                let rand1 = Int.random(min: 1, max: 14)
                if rand1 == 7 {
                    let t1 = Transaction()
                    t1.type = EXPENSE
                    t1.amount = Double.round2(input: Double(Int.random(min: 100, max: 1000)) + Double.random)
                    t1.amountStr = String(t1.amount)
                    t1.account = "Credit Card"
                    t1.category = "Shopping"
                    let rand2 = Int.random(min: 0, max: shoppingLocations.count - 1)
                    t1.location = shoppingLocations[rand2]
                    t1.dt = Date.to(date: date)
                    do {
                        try
                            realm.write {
                                realm.add(t1)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Grocery
            if true {
                let rand1 = Int.random(min: 1, max: 7)
                if rand1 == 4 {
                    let t1 = Transaction()
                    t1.type = EXPENSE
                    t1.amount = Double.round2(input: Double(Int.random(min: 20, max: 120)) + Double.random)
                    t1.amountStr = String(t1.amount)
                    t1.account = "Credit Card"
                    t1.category = "Grocery"
                    let rand2 = Int.random(min: 0, max: groceryLocations.count - 1)
                    t1.location = groceryLocations[rand2]
                    t1.dt = Date.to(date: date)
                    do {
                        try
                            realm.write {
                                realm.add(t1)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Health and Fitness
            if true {
                let rand1 = Int.random(min: 1, max: 60)
                if rand1 == 30 {
                    let t1 = Transaction()
                    t1.type = EXPENSE
                    t1.amount = Double.round2(input: Double(Int.random(min: 100, max: 800)) + Double.random)
                    t1.amountStr = String(t1.amount)
                    t1.account = "Debit Card"
                    t1.category = "Health and Fitness"
                    let rand2 = Int.random(min: 0, max: healthLocations.count - 1)
                    t1.location = healthLocations[rand2]
                    t1.dt = Date.to(date: date)
                    do {
                        try
                            realm.write {
                                realm.add(t1)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Entertainment
            if true {
                let rand1 = Int.random(min: 1, max: 14)
                if rand1 == 7 {
                    let t1 = Transaction()
                    t1.type = EXPENSE
                    let rand2 = Int.random(min: 0, max: entertainmentLocations.count - 1)
                    t1.location = entertainmentLocations[rand2]
                    if t1.location == "Cineplex" {
                        t1.amount = 19.99
                    }
                    else if t1.location == "Escape Zone" || t1.location == "Trapped!" {
                        t1.amount = 29.99
                    }
                    else {
                        t1.amount = Double.round2(input: Double(Int.random(min: 30, max: 150)) + Double.random)
                    }
                    t1.amountStr = String(t1.amount)
                    t1.account = "Credit Card"
                    t1.category = "Entertainment"
                    t1.dt = Date.to(date: date)
                    do {
                        try
                            realm.write {
                                realm.add(t1)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Online Shopping
            if true {
                let rand1 = Int.random(min: 1, max: 14)
                if rand1 == 7 {
                    let t1 = Transaction()
                    t1.type = EXPENSE
                    t1.amount = Double.round2(input: Double(Int.random(min: 20, max: 600)) + Double.random)
                    t1.amountStr = String(t1.amount)
                    t1.account = "Debit Card"
                    t1.category = "Online Shopping"
                    t1.dt = Date.to(date: date)
                    do {
                        try
                            realm.write {
                                realm.add(t1)
                        }
                    }
                    catch {
                    }
                }
            }
            
            // Travelling
            if Date.to(date: date) == "12/24/2018" {
                let t1 = Transaction()
                t1.type = EXPENSE
                t1.amount = 2019.88
                t1.amountStr = String(t1.amount)
                t1.account = "Debit Card"
                t1.category = "Travelling"
                t1.location = "Australia"
                t1.text = "Have a great time :D"
                t1.dt = Date.to(date: date)
                do {
                    try
                        realm.write {
                            realm.add(t1)
                    }
                }
                catch {
                }
            }
            
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
    }
}
