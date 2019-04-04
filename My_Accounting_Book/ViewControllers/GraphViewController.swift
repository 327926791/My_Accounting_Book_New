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
import CloudKit
import SwiftEntryKit

class GraphViewController: UIViewController {
    let database = CKContainer.default().privateCloudDatabase
    
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
    
    @IBAction func backupButtonPressed(_ sender: Any) {
        saveToCloud()
    }
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        readFromCloud()
    }
    
    func saveToCloud(){
        let data = realm.objects(Transaction.self)
        if data.count > 0 {
            let query = CKQuery(recordType: "Backup", predicate: NSPredicate(value: true))
            database.perform(query, inZoneWith: nil) { (records, _) in
                guard let records = records else {return}
                for record in records{
                    self.database.delete(withRecordID: record.recordID, completionHandler: { (_, _) in})
                }
            }
            
            for row in data{
                let newNote = CKRecord(recordType: "Backup")
                newNote.setValue(row.id, forKey: "id")
                newNote.setValue(row.type == true ? "true" : "false", forKey: "type")
                newNote.setValue(row.amount, forKey: "amount")
                newNote.setValue(row.account, forKey: "account")
                newNote.setValue(row.category, forKey: "category")
                newNote.setValue(row.dt, forKey: "dt")
                database.save(newNote) { (record, error) in
                    guard record != nil else {return}
                    print("saved successfully")
                }
            }
            ShowSuccessMessage(text: "Successfully backed up")
        }
    }
    
    
    var notes = [CKRecord]()
    // gets back everything
    func readFromCloud(){
        let query = CKQuery(recordType: "Backup", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, _) in
            guard let records = records else {return}
            // pull the data out of records
            self.notes = records
            
            DispatchQueue.main.async {
                try! self.realm.write {
                    self.realm.deleteAll()
                }
                
                for record in records{
                    let t = Transaction()
                    t.id = (record.value(forKey: "id") as? String)!
                    t.type = record.value(forKey: "type")as? String == "true" ? true : false
                    t.account = record.value(forKey: "account") as? String
                    t.amount = (record.value(forKey: "amount") as? Double)!
                    t.category = record.value(forKey: "category") as? String
                    t.dt = record.value(forKey: "dt") as? String
                    t.amountStr = String(t.amount)
                    t.location = ""
                    t.text = ""
                    do {
                        try
                            self.realm.write {
                                self.realm.add(t)
                        }
                    }
                    catch {
                        print(error)
                    }
                }
                self.ShowSuccessMessage(text: "Database restored from iCloud")
            }
        }
    }
    
    @IBAction func plotButtonPressed(_ sender: Any) {
        let data = realm.objects(Transaction.self)
        var allCategorySelectedFlag: Bool = false
        var categoryAmountDict: [String: Double] = [:]
        if categorySelectionIndexTracker.contains(0){ // 0 is the index for "All Categories"
            allCategorySelectedFlag = true
        }

        chartView.chartDescription?.enabled = false
        chartView.drawHoleEnabled = false
        chartView.rotationAngle = 0
        chartView.rotationEnabled = false
        chartView.isUserInteractionEnabled = false
        
        var hasValue : Bool = false
        
        for row in data{
            let categoryIndexForThisRow = categories.firstIndex(of: row.category!)
            let accountIndexForThisRow = accounts.firstIndex(of: row.account!)
            if categoryIndexForThisRow != nil && accountIndexForThisRow != nil{
                if ( allCategorySelectedFlag == true || categorySelectionIndexTracker.contains(categoryIndexForThisRow!+1) ) &&
                    accountSelectionIndexTracker.contains(accountIndexForThisRow!) &&
                    (convertDateToInt(row.dt!) <= convertDateToInt(endDate) && convertDateToInt(row.dt!) >= convertDateToInt(startDate)){
                    hasValue = true
                    if categoryAmountDict[row.category!] != nil{
                        categoryAmountDict[row.category!]! += row.amount
                    } else{
                        categoryAmountDict[row.category!] = row.amount
                    }
                }
            }
        }

        if(!hasValue){
            return
        }
    
        let c1 = UIColor(rgb: 0x3A015C)
        let c2 = UIColor(rgb: 0x4F0147)
        let c3 = UIColor(rgb: 0x35012C)
        let c4 = UIColor(rgb: 0x290025)
        let c5 = UIColor(rgb: 0x11001C)

        var colors: [NSUIColor] = Array()
        var entries: [PieChartDataEntry] = Array()
        for (categoryName, amount) in categoryAmountDict{
            entries.append(PieChartDataEntry(value: amount, label: categoryName))
//            print("Category Name: \(categoryName), Amount: \(amount)")
        }
        
        let dataSet = PieChartDataSet(values: entries, label: "")
        dataSet.colors = [c1, c2, c3, c4, c5]
        dataSet.drawValuesEnabled = false
        chartView.data = PieChartData(dataSet: dataSet)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectView.delegate = self
        selectView.dataSource = self
        
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
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var selectView: UITableView!
    
    private func ShowSuccessMessage(text: String) {
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .gradient(gradient: .init(colors: [.blue, .lightGray], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: 300), height: .intrinsic)
        
        let title = EKProperty.LabelContent(text: "Success", style: .init(font: UIFont (name: "HelveticaNeue-Light", size: 20)!, color: UIColor.yellow))
        let description = EKProperty.LabelContent(text: text, style: .init(font: UIFont (name: "HelveticaNeue-Light", size: 15)!, color: UIColor.yellow))
        let image = EKProperty.ImageContent(image: UIImage(named: "Header")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
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
                        
                        self.selectView.reloadData()
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
                        
                        self.selectView.reloadData()
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
        view.tintColor = UIColor.blue // back ground color of header
        
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
