//
//  GraphViewController.swift
//  My_Accounting_Book
//
//  Created by Mike Sun on 2019-01-13.
//  Copyright © 2019 Team_927. All rights reserved.
//

import UIKit
import Charts
import RealmSwift
import DatePickerDialog

class GraphViewController: UIViewController {

    let realm = try! Realm()
    
    let STARTDATE = "Start Date"
    let ENDDATE = "End Date"
    let ALLCATEGORIES = "All Categories"
    let sections = ["Date", "Category", "Account"]
    
    
    
    var startDate: String = ""
    var endDate: String = ""
    var selectedCategories = [String]()
    var dateFlag = DateFlagEnum.startDate
    var categorySelectionIndexTracker: [Int] = Array()
    var accountSelectionIndexTracker: [Int] = Array()
    
    
    var items = [[String]]()
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieView: PieChartView!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func graphButtonPressed(_ sender: Any) {
        let data = realm.objects(Transaction.self)

        var allCategorySelectedFlag: Bool = false
        var categoryAmountDict: [String: Double] = [:]
        if categorySelectionIndexTracker.contains(0){ // 0 is the index for "All Categories"
            allCategorySelectedFlag = true
        }
        
        

        pieView.chartDescription?.enabled = false
        pieView.drawHoleEnabled = false
        pieView.rotationAngle = 0
        pieView.rotationEnabled = false
        pieView.isUserInteractionEnabled = false

        for row in data{
            
            let categoryIndexForThisRow = categories.firstIndex(of: row.category!)
            let accountIndexForThisRow = accounts.firstIndex(of: row.account!)
            if categoryIndexForThisRow != nil && accountIndexForThisRow != nil{
                if ( allCategorySelectedFlag == true || categorySelectionIndexTracker.contains(categoryIndexForThisRow!+1) ) &&
                    accountSelectionIndexTracker.contains(accountIndexForThisRow!) &&
                    (convertDateToInt(row.dt!) <= convertDateToInt(endDate) && convertDateToInt(row.dt!) >= convertDateToInt(startDate)){
                    
                }
            }
            
        }
        
     
        
//        let c1 = NSUIColor(hex: 0x3A015C)
//        let c2 = NSUIColor(hex: 0x4F0147)
//        let c3 = NSUIColor(hex: 0x35012C)
//        let c4 = NSUIColor(hex: 0x290025)
//        let c5 = NSUIColor(hex: 0x11001C)
//
//        var colors: [NSUIColor] = Array()
//
//
//        var entries: [PieChartDataEntry] = Array()
//        var hasValue = false
//
//        if amountTransportation > 0{
//            entries.append(PieChartDataEntry(value: Double(amountTransportation), label: "Transportation"))
//
//            colors.append(c1)
//            hasValue = true
//        }
//
//        if(!hasValue){
//            return
//        }
        
//        let dataSet = PieChartDataSet(values: entries, label: "")
//        dataSet.colors = colors
//        dataSet.drawValuesEnabled = false
//        pieView.data = PieChartData(dataSet: dataSet)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let todayDate: String = formatter.string(from: Date())
        startDate = todayDate
        endDate = todayDate
        
        var prependArray = ["\(ALLCATEGORIES)"]
        prependArray.append(contentsOf: categories)
        items.append([String]())
        items[0].append("\(STARTDATE): \(todayDate)")
        items[0].append("\(ENDDATE): \(todayDate)")
        items.append([String]())
        items[1].append(contentsOf: prependArray)
        items.append([String]())
        items[2].append(contentsOf: accounts)
        
    }
    
    func convertDateToInt(_ dateString: String) -> Int{
        var generatedDate: String = ""
        let strArr = dateString.split(separator: "/")
        
        var newStrArr = [String]()
        
        newStrArr.append("\(strArr[2])")
        newStrArr.append("\(strArr[0])")
        newStrArr.append("\(strArr[1])")
        
        for str in newStrArr{
            if str.count < 2{
                generatedDate.append("0\(str)")
            }else{
                generatedDate.append("\(str)")
            }
        }
        
        return Int(generatedDate)!
    }
}

extension GraphViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.section][indexPath.row]
        
        switch selectedItem{
        case let str where str.contains(STARTDATE):
            if indexPath.section == 0{
                dateFlag = DateFlagEnum.startDate
                
                
                DatePickerDialog().show("Select Start Date", doneButtonTitle: "OK", cancelButtonTitle: "Cancel", datePickerMode: .date) {
                    (date) -> Void in
                    if let dt = date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM/dd/yyyy"
                        
                        
                        let pickedDate = formatter.string(from: dt)
                        if self.convertDateToInt(pickedDate) > self.convertDateToInt(self.endDate){
                            self.startDate = pickedDate
                            self.endDate = pickedDate
                            self.items[0][0] = "\(self.STARTDATE): \(formatter.string(from: dt))"
                            self.items[0][1] = "\(self.ENDDATE): \(formatter.string(from: dt))"
                        }else{
                            self.items[0][0] = "\(self.STARTDATE): \(formatter.string(from: dt))"
                            self.startDate = pickedDate
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
            break;
        case let str where str.contains(ENDDATE):
            if indexPath.section == 0{
                dateFlag = DateFlagEnum.endDate
                
                DatePickerDialog().show("Select End Date", doneButtonTitle: "OK", cancelButtonTitle: "Cancel", datePickerMode: .date) {
                    (date) -> Void in
                    if let dt = date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM/dd/yyyy"
                        
                        let pickedDate = formatter.string(from: dt)
                        if self.convertDateToInt(pickedDate) < self.convertDateToInt(self.startDate){
                            self.startDate = pickedDate
                            self.endDate = pickedDate
                            self.items[0][0] = "\(self.STARTDATE): \(formatter.string(from: dt))"
                            self.items[0][1] = "\(self.ENDDATE): \(formatter.string(from: dt))"
                        }else{
                            self.items[0][1] = "\(self.ENDDATE): \(formatter.string(from: dt))"
                            self.endDate = pickedDate
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
            break;
        case ALLCATEGORIES:
            
            if categorySelectionIndexTracker.count == 0{
                categorySelectionIndexTracker.append(indexPath.row)
            }else{
                if !categorySelectionIndexTracker.contains(0){
                    // contains "All Categories", "deselect" all other categories, and set "All Categories" to "true"
                    categorySelectionIndexTracker.removeAll()
                    categorySelectionIndexTracker.append(indexPath.row)
                }
                else{
                    categorySelectionIndexTracker.removeAll()
                }
            }
            
            break;
            
        default:
            if indexPath.section == 1 {
                //remove "All Categories" if it's set
                categorySelectionIndexTracker = categorySelectionIndexTracker.filter{
                    $0 != 0
                }
                
                // "Flip other ones"
                if categorySelectionIndexTracker.contains(indexPath.row){
                    categorySelectionIndexTracker = categorySelectionIndexTracker.filter{
                        $0 != indexPath.row
                    }
                }else{
                    categorySelectionIndexTracker.append(indexPath.row)
                }
            }else{
                // Accounts
                if accountSelectionIndexTracker.contains(indexPath.row){
                    accountSelectionIndexTracker = accountSelectionIndexTracker.filter{
                        $0 != indexPath.row
                    }
                }else{
                    accountSelectionIndexTracker.append(indexPath.row)
                }
            }
            break;
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // set header styling
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.red // back ground color of header
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    // set header titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        
        if indexPath.section != 0{
            if indexPath.section == 1{
                if categorySelectionIndexTracker.contains(indexPath.row){
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
            }else if indexPath.section == 2{
                if accountSelectionIndexTracker.contains(indexPath.row)
                {
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
            }
        }
        return cell
    }
    
    
}
