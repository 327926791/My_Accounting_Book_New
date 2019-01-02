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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // *** Changes by Chi ****
        let re = RandomEntries()
        re.GenerateRandomEntries(realm: realm)
        
        let ret = loadDisplay()
        
        updateLables(year:ret.year,month:ret.month)
        //print("\(ret.year) \(ret.month)")
        displayMonthDropDown.setTitle("\(ret.year)-\(ret.month)", for: UIControl.State.normal)
        
        displayTransactions(filterCondition: nil, sortCondition: nil, ascendingOrNot: nil, year: ret.year, month: ret.month)
        
        MonthDropdown.anchorView = displayMonthDropDown
        MonthDropdown.direction = .bottom
        MonthDropdown.dataSource = DropdownButtonDisplay
        MonthDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.MonthDropdown.selectedItem != nil {
                self.displayMonthDropDown.setTitle(self.MonthDropdown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
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
                self.displayTransactions(filterCondition: nil, sortCondition: nil, ascendingOrNot: nil, year: year, month: month)
                
            }
            
            }
        }
        
            
        
    }
    
    @IBOutlet weak var monthlyIncome: UILabel!
    @IBOutlet weak var monthlyExpense: UILabel!
    
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
    
    

    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    @IBOutlet weak var label21: UILabel!
    @IBOutlet weak var label22: UILabel!
    @IBOutlet weak var label31: UILabel!
    @IBOutlet weak var label32: UILabel!
    
    func displayTransactions ( filterCondition : String?, sortCondition : String?, ascendingOrNot : Bool?, year : String, month : String) {
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
        
        
        if sortCondition == nil {
            sort_Condition = "dt"
        }else{
            sort_Condition = sortCondition!
        }
        if ascendingOrNot == nil {
            ascending_OrNot = false
        }else{
            ascending_OrNot = ascendingOrNot!
        }
        if filterCondition == nil {
            transactions = realm.objects(Transaction.self).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
        }else{
            transactions = realm.objects(Transaction.self).filter("\(filterCondition)").sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
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
                    if var cate = item.category{
                        label1 = label1 + cate
                    }
                    if var loc = item.location{
                        label1 = label1 + "@" + loc
                    }
                    if var acnt = item.account{
                        label2 = acnt + "\n"
                    }else{
                        label2 = "No account specified\n"
                    }
                    var amt = item.amount
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
