//
//  StartPageViewController.swift
//  My_Accounting_Book
//
//  Created by Yingqian Gu on 2018-12-29.
//  Copyright © 2018 Team_927. All rights reserved.
//

import UIKit
import RealmSwift
import DropDown

class StartPageViewController: UIViewController {
    var DropdownButtonDisplay = [String]()
    
    
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 2
    ))
    
    
    private var MonthDropdown = DropDown()
    private var categoryFilterDropdown = DropDown()
    private var sortDropdown = DropDown()
    var sortChoice = ["date up", "date down", "amount up", "amount down"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ret = loadDisplay()
        
        updateLables(year:ret.year,month:ret.month)
        //print("\(ret.year) \(ret.month)")
        displayMonthDropDown.setTitle("\(ret.year)-\(ret.month)", for: UIControl.State.normal)
        
        displayTransactions(filterCondition: nil, sortCondition: nil, year: ret.year, month: ret.month)
        
        MonthDropdown.anchorView = displayMonthDropDown
        MonthDropdown.direction = .bottom
        MonthDropdown.dataSource = DropdownButtonDisplay
        MonthDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.MonthDropdown.selectedItem != nil {
                self.displayMonthDropDown.setTitle(self.MonthDropdown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        categoryFilterDropdown.anchorView = categoryFilterButton
        categoryFilterDropdown.direction = .bottom
        categoryFilterDropdown.dataSource = categories
        if categoryFilterDropdown.selectedItem == nil{
            print("category filter dropdown init select nil")
        }
        categoryFilterDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.categoryFilterDropdown.selectedItem != nil {
            self.categoryFilterButton.setTitle("filter by", for: UIControl.State.normal)
            }
        }
        
        sortDropdown.anchorView = sortButton
        sortDropdown.direction = .bottom
        sortDropdown.dataSource = sortChoice
        if sortDropdown.selectedItem == nil{
            print("sort dropdown init select nil")
        }
        sortDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.sortDropdown.selectedItem != nil {
            self.sortButton.setTitle("sort by", for: UIControl.State.normal)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    //press select month button
    @IBOutlet weak var displayMonthDropDown: UIButton!
    @IBAction func displayMonth(_ sender: Any) {
        MonthDropdown.show()
        MonthDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.MonthDropdown.selectedItem != nil {
            self.displayMonthDropDown.setTitle(self.MonthDropdown.selectedItem!, for: UIControl.State.normal)
            print("select" + self.MonthDropdown.selectedItem!)
            if let title = self.displayMonthDropDown.title(for: UIControl.State.normal){
                var year : String
                var month : String
                year = title.substring(to: title.index(title.startIndex, offsetBy: 4))
                let index1 = title.index(title.startIndex, offsetBy: 5)
                let index2 = title.index(title.startIndex, offsetBy: 6)
                month = String(title[index1 ... index2])
                print(year,month)
                self.updateLables(year: year, month: month)
                var categoryFilterQuery : String?
                var sortQuery : String?
                if self.categoryFilterDropdown.selectedItem != nil{
                    categoryFilterQuery = "category == \"\(self.categoryFilterDropdown.selectedItem!)\""
                }else{
                    categoryFilterQuery = nil
                }
                
                if self.sortDropdown.selectedItem != nil{
                    sortQuery = self.sortDropdown.selectedItem!
                }else{
                    sortQuery = nil
                }
                self.displayTransactions(filterCondition: categoryFilterQuery, sortCondition: sortQuery, year: year, month: month)
                
            }
            
            }
        }
        
            
        
    }
    
    @IBOutlet weak var monthlyIncome: UILabel!
    @IBOutlet weak var monthlyExpense: UILabel!
    //generate date select dropdown list and return current year and month
    func loadDisplay() -> (year:String, month:String){
        var minDate_Year : String
        var minDate_Month : String
        var curDate_Year : String
        var curDate_Month : String
        var Date_Array = [String]()
        let transactions = realm.objects(Transaction.self)
        for item in transactions {
            if let a = item.dt {
                
                if !Date_Array.contains(a){
                    Date_Array.append(a)
                }
            }
        }
        Date_Array.sort()
        //get earliest year and month
        let min = Date_Array[0]
        minDate_Year = min.substring(to: min.index(min.startIndex, offsetBy: 4))
        let index1 = min.index(min.startIndex, offsetBy: 5)
        let index2 = min.index(min.startIndex, offsetBy: 6)
        minDate_Month = String(min[index1 ... index2])
        //print ("\(minDate_Year)-\(minDate_Month)\n")
        //get current year and month
        let curDateYearFormatter = DateFormatter.init()
        curDateYearFormatter.dateFormat = "yyyy"
        curDate_Year = curDateYearFormatter.string(from: Date.init())
        let curDateMonthFormatter = DateFormatter.init()
        curDateMonthFormatter.dateFormat = "MM"
        curDate_Month = curDateMonthFormatter.string(from: Date.init())
        
        //print ("\(curDate_Year)-\(curDate_Month)\n")
        
        // *** Changes by Chi ****
        if Int(minDate_Year) == nil || Int(curDate_Year) == nil {
            return ("2018", "12")
        }
        
        for i in Int(minDate_Year)! ... Int(curDate_Year)! {
            if i < Int(curDate_Year)! && i == Int(minDate_Year)! {
                for j in Int(minDate_Month)! ... 12 {
                    print("\(i)-" + String(format:"%02d", j))
                    DropdownButtonDisplay.append("\(i)-" + String(format:"%02d", j))
                }
            }else if i < Int(curDate_Year)! && i != Int(minDate_Year)!{
                for j in 1 ... 12 {
                    print("\(i)-" + String(format:"%02d", j))
                    DropdownButtonDisplay.append("\(i)-" + String(format:"%02d", j))
                }
            }else if i == Int(curDate_Year)! && i == Int(minDate_Year)! {
                for j in Int(minDate_Month)! ... Int(curDate_Month)! {
                    print("\(i)-" + String(format:"%02d", j))
                    DropdownButtonDisplay.append("\(i)-" + String(format:"%02d", j))
                }
            }else if i == Int(curDate_Year)! && i != Int(minDate_Year)! {
                for j in 1 ... Int(curDate_Month)! {
                    print("\(i)-" + String(format:"%02d", j))
                    DropdownButtonDisplay.append("\(i)-" + String(format:"%02d", j))
                }
            }else{
                print("ops")
            }
        }
        //print(DropdownButtonDisplay)
        
        return (curDate_Year,curDate_Month)
        
    }
    //update monthly income and expense labels
    func updateLables(year : String, month : String){
        var sum_expense : Double
        var sum_income : Double
        sum_expense = 0.0
        sum_income = 0.0
        
        let transactions = realm.objects(Transaction.self)
        for item in transactions {
            let type = item.type
            let a = item.amount
            if let date = item.dt{
                let itemYear = date.substring(to: date.index(date.startIndex, offsetBy: 4))
                let index1 = date.index(date.startIndex, offsetBy: 5)
                let index2 = date.index(date.startIndex, offsetBy: 6)
                let itemMonth = String(date[index1 ... index2])
                if itemYear == year && itemMonth == month {
                    if type == true {
                        sum_expense += a
                    }else{
                        sum_income += a
                    }
                }
            }
        }
        
        monthlyIncome.text = "Monthly Income: \(sum_income)"
        monthlyExpense.text = "Monthly Expense: \(sum_expense)"
    
       
    }
    
    


//    @IBOutlet weak var categoryFilterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    @IBOutlet weak var categoryFilterButton: UIButton!
    
    @IBAction func pressCategoryFilterButton(_ sender: Any) {
        categoryFilterDropdown.show()
        categoryFilterDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.categoryFilterDropdown.selectedItem != nil {
            self.categoryFilterButton.setTitle(self.categoryFilterDropdown.selectedItem!, for: UIControl.State.normal)
            print("select filter " + self.categoryFilterDropdown.selectedItem!)
            var year : String
            var month : String
            if let title = self.displayMonthDropDown.title(for: UIControl.State.normal){
                year = title.substring(to: title.index(title.startIndex, offsetBy: 4))
                let index1 = title.index(title.startIndex, offsetBy: 5)
                let index2 = title.index(title.startIndex, offsetBy: 6)
                month = String(title[index1 ... index2])
                var query : String
                query = "category == \"\(self.categoryFilterDropdown.selectedItem!)\""
                print (query)
                self.displayTransactions(filterCondition: query, sortCondition: self.sortDropdown.selectedItem, year: year, month: month)
            }
            }
        }
    }

    
    @IBAction func pressSortButton(_ sender: Any) {
        sortDropdown.show()
        sortDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.sortDropdown.selectedItem != nil {
            self.sortButton.setTitle(self.sortDropdown.selectedItem!, for: UIControl.State.normal)
            print("select sort " + self.sortDropdown.selectedItem!)
            var year : String
            var month : String
            if let title = self.displayMonthDropDown.title(for: UIControl.State.normal){
                year = title.substring(to: title.index(title.startIndex, offsetBy: 4))
                let index1 = title.index(title.startIndex, offsetBy: 5)
                let index2 = title.index(title.startIndex, offsetBy: 6)
                month = String(title[index1 ... index2])
                self.displayTransactions(filterCondition: "category == \"\(self.categoryFilterDropdown.selectedItem!)\"", sortCondition: self.sortDropdown.selectedItem, year: year, month: month)
                //"category == " + self.categoryFilterDropdown.selectedItem!
            }
            }
        }
    }
    
    
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    @IBOutlet weak var label21: UILabel!
    @IBOutlet weak var label22: UILabel!
    @IBOutlet weak var label31: UILabel!
    @IBOutlet weak var label32: UILabel!
    
    func displayTransactions ( filterCondition : String?, sortCondition : String?, year : String, month : String) {
        var label1 : String
        var label2 : String
        var sort_Condition : String
        var ascending_OrNot : Bool
        label1 = ""
        label2 = ""
        var count : Int
        count = 0
        let transactions : Results<Transaction>
        
        label11.text = ""
        label12.text = ""
        label21.text = ""
        label22.text = ""
        label31.text = ""
        label32.text = ""
        
        switch (sortCondition){
        case "date down":
            sort_Condition = "dt"
            ascending_OrNot = false
            break
        case "date up":
            sort_Condition = "dt"
            ascending_OrNot = true
            break
        case "amount down":
            sort_Condition = "amount"
            ascending_OrNot = false
            break
        case "amount up":
            sort_Condition = "amount"
            ascending_OrNot = true
            break
        default:
            sort_Condition = "dt"
            ascending_OrNot = false
            break
        }
        
        if filterCondition == nil {
            transactions = realm.objects(Transaction.self).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
        }else{
            print (filterCondition!)
            transactions = realm.objects(Transaction.self).filter(filterCondition!).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
        }
        
        for item in transactions {
            
            if var dt = item.dt{
                dt = dt.substring(to: dt.index(dt.startIndex, offsetBy: 10))
                let itemYear = dt.substring(to: dt.index(dt.startIndex, offsetBy: 4))
                let index1 = dt.index(dt.startIndex, offsetBy: 5)
                let index2 = dt.index(dt.startIndex, offsetBy: 6)
                let itemMonth = String(dt[index1 ... index2])
                if itemYear == year && itemMonth == month {
                    count = count + 1
                    label1 = dt + "\n"                    
                    if let cate = item.category{
                        label1 = label1 + cate
                    }
                    if let loc = item.location{
                        label1 = label1 + "@" + loc
                    }
                    if let acnt = item.account{
                        label2 = acnt + "\n"
                    }else{
                        label2 = "No account specified\n"
                    }
                    let amt = item.amount
                    label2 = label2 + String(amt)
                    if count == 1{
                        label11.text = label1
                        label12.text = label2
                    }else if count == 2{
                        label21.text = label1
                        label22.text = label2
                    }else if count == 3{
                        label31.text = label1
                        label32.text = label2
                    }
                }
            }

        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
