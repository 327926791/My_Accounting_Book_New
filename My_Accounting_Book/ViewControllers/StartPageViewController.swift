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
        schemaVersion: 1
    ))
    
    
    private var MonthDropdown = DropDown()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let ret = loadDisplay()
        
        updateLables(year:ret.year,month:ret.month)
        print("\(ret.year) \(ret.month)")
        
        
        MonthDropdown.anchorView = displayMonthDropDown
        MonthDropdown.direction = .bottom
        MonthDropdown.dataSource = DropdownButtonDisplay
        MonthDropdown.cancelAction = { [unowned self] in
            if self.MonthDropdown.selectedItem != nil {
                self.displayMonthDropDown.setTitle(self.MonthDropdown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBOutlet weak var displayMonthDropDown: UIButton!
    @IBAction func displayMonth(_ sender: Any) {
        MonthDropdown.show()
        if self.MonthDropdown.selectedItem != nil {
            self.displayMonthDropDown.setTitle(self.MonthDropdown.selectedItem!, for: UIControl.State.normal)
        }
        if let title = self.displayMonthDropDown.title(for: UIControl.State.normal){
            print(title)
            var year : String
            var month : String
            year = title.substring(to: title.index(title.startIndex, offsetBy: 4))
            let index1 = title.index(title.startIndex, offsetBy: 5)
            let index2 = title.index(title.startIndex, offsetBy: 6)
            month = String(title[index1 ... index2])
            updateLables(year: year, month: month)
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
        let min = Date_Array[0]
        minDate_Year = min.substring(to: min.index(min.startIndex, offsetBy: 4))
        let index1 = min.index(min.startIndex, offsetBy: 5)
        let index2 = min.index(min.startIndex, offsetBy: 6)
        minDate_Month = String(min[index1 ... index2])
        print ("\(minDate_Year)-\(minDate_Month)\n")
        
        let curDateYearFormatter = DateFormatter.init()
        curDateYearFormatter.dateFormat = "yyyy"
        curDate_Year = curDateYearFormatter.string(from: Date.init())
        let curDateMonthFormatter = DateFormatter.init()
        curDateMonthFormatter.dateFormat = "MM"
        curDate_Month = curDateMonthFormatter.string(from: Date.init())
        
        print ("\(curDate_Year)-\(curDate_Month)\n")
        for i in Int(minDate_Year)! ... Int(curDate_Year)! {
            for j in Int(minDate_Month)! ... Int(curDate_Month)! {
                DropdownButtonDisplay.append("\(i)-" + String(format:"%02d", j))
            }
        }
        print(DropdownButtonDisplay)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
