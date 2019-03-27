//
//  CSVViewController.swift
//  My_Accounting_Book
//
//  Created by Mike Sun on 2019-01-12.
//  Copyright © 2019 Team_927. All rights reserved.
//

import UIKit
import RealmSwift
import DatePickerDialog


enum DateFlagEnum{
    case startDate
    case endDate
}


class CSVViewController: UIViewController {
    
    
    let STARTDATE = "Start Date"
    let ENDDATE = "End Date"
    let ALLCATEGORIES = "All Categories"
    
    
    let sections = ["Date", "Category", "Account"]
    let realm = try! Realm()
    
    var startDate: String = ""
    var endDate: String = ""
    var selectedCategories = [String]()
    var dateFlag = DateFlagEnum.startDate
    var categorySelectionIndexTracker: [Int] = Array()
    var accountSelectionIndexTracker: [Int] = Array()
    
    // TEST IF REFERNCE OR VALUE
    var items = [[String]]()
    

    @IBOutlet weak var tableView: UITableView!
    

 
    @IBAction func generateButtonPressed(_ sender: Any) {
        /* indexing for category selected is index - 1, because the first
         element is "All Categories", which is a placehold not presentd
         in the actual category
         */
        
        let data = realm.objects(Transaction.self)
        let fileName = "spendingRecord.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        print(path)
        
        
        var csvText: String = ""
        
        var allCategorySelectedFlag: Bool = false
        
        var csvHeaderAndBody = ""
        // body
        if categorySelectionIndexTracker.contains(0){ // 0 is the index for "All Categories"
            allCategorySelectedFlag = true
        }
        for row in data{
            
            let categoryIndexForThisRow = categories.firstIndex(of: row.category!)
            let accountIndexForThisRow = accounts.firstIndex(of: row.account!)
            if categoryIndexForThisRow != nil && accountIndexForThisRow != nil{
                if ( allCategorySelectedFlag == true || categorySelectionIndexTracker.contains(categoryIndexForThisRow!+1) ) &&
                    accountSelectionIndexTracker.contains(accountIndexForThisRow!) &&
                    (convertDateToInt(row.dt!) <= convertDateToInt(endDate) && convertDateToInt(row.dt!) >= convertDateToInt(startDate)){
                    // Date
                    csvText.append("\(row.dt!), ")
                    // Amount
                    csvText.append("\(row.amount), ")
                    // Category
                    csvText.append("\(row.category!), ")
                    // Account
                    csvText.append("\(row.account!), ")
                    // location
                    csvText.append("\(row.location!)\n")
                }
            }
            
        }
        
        if !csvText.isEmpty{
            csvHeaderAndBody = ("Date, Amount, Category, Account, Location\n")
            csvHeaderAndBody.append(contentsOf: csvText)
            // save csv file to FileURL
            do{
                try csvHeaderAndBody.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
            }catch{
                print("Failed to create file")
                print(error)
            }
        }else{
            let alert = UIAlertController(title: "Error", message: "No Entries To Generate, Try Setting Different Conditions.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
  
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    private func convertDateToInt(_ dateString: String) -> Int{
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

extension CSVViewController: UITableViewDelegate, UITableViewDataSource{
    
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
