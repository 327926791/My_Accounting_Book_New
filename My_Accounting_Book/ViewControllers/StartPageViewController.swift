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
import SideMenu

class StartPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var transcriptTalbeView: UITableView!
    var label1Array : [String] = [String]()
    var label2Array : [String] = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return label1Array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTranscriptCell", for: indexPath) as! TranscriptTableViewCell
        cell.tableCellLabel1.text = label1Array[indexPath.row]
        cell.tableCellLabel2.text = label2Array[indexPath.row]
        return cell
    }
    
    var DropdownButtonDisplay = [String]()
    
    
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 2
    ))
    
    
    private var MonthDropdown = DropDown()
    private var typeFilterDropdown = DropDown()
    private var categoryFilterDropdown = DropDown()
    private var accountFilterDropdown = DropDown()
    private var sortDropdown = DropDown()
    var sortChoice = ["date up", "date down", "amount up", "amount down"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: VisionViewController())
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        
        transcriptTalbeView.rowHeight = 120
        transcriptTalbeView.allowsSelection = false
        transcriptTalbeView.delegate = self
        transcriptTalbeView.dataSource = self
        transcriptTalbeView.register(UINib(nibName: "TranscriptTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTranscriptCell")
        
        let ret = loadDisplay()
        
        updateLables(year:ret.year,month:ret.month)
        //print("\(ret.year) \(ret.month)")
        displayMonthDropDown.setTitle("\(ret.year)-\(ret.month)", for: UIControl.State.normal)
        
        displayTransactions()
        
        MonthDropdown.anchorView = displayMonthDropDown
        MonthDropdown.direction = .bottom
        MonthDropdown.dataSource = DropdownButtonDisplay
        MonthDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.MonthDropdown.selectedItem != nil {
            self.displayMonthDropDown.setTitle(self.MonthDropdown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        typeFilterDropdown.anchorView = typeFilterButton
        typeFilterDropdown.direction = .bottom
        typeFilterDropdown.dataSource = ["Income", "Expense"]
        if typeFilterDropdown.selectedItem == nil{
            self.typeFilterButton.setTitle("All", for: UIControl.State.normal)
        }
        
        categoryFilterDropdown.anchorView = categoryFilterButton
        categoryFilterDropdown.direction = .bottom
        categoryFilterDropdown.dataSource = categories
        if categoryFilterDropdown.selectedItem == nil{
           // print("category filter dropdown init select nil")
        }
        categoryFilterDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.categoryFilterDropdown.selectedItem != nil {
            self.categoryFilterButton.setTitle("Category", for: UIControl.State.normal)
            }
        }
        
        accountFilterDropdown.anchorView = accountFilterButton
        accountFilterDropdown.direction = .bottom
        accountFilterDropdown.dataSource = accounts
        if accountFilterDropdown.selectedItem == nil{
            //print("account filter dropdown init select nil")
        }
        accountFilterDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.accountFilterDropdown.selectedItem != nil {
            self.accountFilterButton.setTitle("Account", for: UIControl.State.normal)
            }
        }
        
        sortDropdown.anchorView = sortButton
        sortDropdown.direction = .bottom
        sortDropdown.dataSource = sortChoice
        if sortDropdown.selectedItem == nil{
            //print("sort dropdown init select nil")
        }
        sortDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.sortDropdown.selectedItem != nil {
            self.sortButton.setTitle("Sort by", for: UIControl.State.normal)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        super.viewDidAppear(animated)
        realm = try! Realm(configuration: Realm.Configuration(
            schemaVersion: 2
        ))
        
        let ret = loadDisplay()
        if let selection = displayMonthDropDown.title(for: UIControl.State.normal) {
            let year = selection.substring(toIndex: 4)
            let month = selection.substring(fromIndex: 5)
            print ("get title: \(year)-\(month)")
            updateLables(year:year,month:month)
            displayMonthDropDown.setTitle("\(year)-\(month)", for: UIControl.State.normal)
        }else{
            updateLables(year:ret.year,month:ret.month)
            displayMonthDropDown.setTitle("\(ret.year)-\(ret.month)", for: UIControl.State.normal)
        }

        displayTransactions()
        
    }
    
    //press select month button
    @IBOutlet weak var displayMonthDropDown: UIButton!
    @IBAction func displayMonth(_ sender: Any) {
        MonthDropdown.show()
        MonthDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.MonthDropdown.selectedItem != nil {
            self.displayMonthDropDown.setTitle(self.MonthDropdown.selectedItem!, for: UIControl.State.normal)
            //print("select" + self.MonthDropdown.selectedItem!)
            if let title = self.displayMonthDropDown.title(for: UIControl.State.normal){
                var year : String
                var month : String                
                year = title.substring(toIndex: 4)
                month = title.substring(fromIndex: 5)
                //print(year,month)
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
                self.displayTransactions()
                
            }
            
            }
        }
    }
    
    @IBOutlet weak var monthlyIncome: UILabel!
    @IBOutlet weak var monthlyExpense: UILabel!
    //generate date select dropdown list and return current year and month
    func loadDisplay() -> (year:String, month:String){
        DropdownButtonDisplay.removeAll()
        var minDate_Year : String = "9999"
        var minDate_Month : String = "99"
        var curDate_Year : String
        var curDate_Month : String
        
        //get current year and month
        let curDateYearFormatter = DateFormatter.init()
        curDateYearFormatter.dateFormat = "yyyy"
        curDate_Year = curDateYearFormatter.string(from: Date.init())
        let curDateMonthFormatter = DateFormatter.init()
        curDateMonthFormatter.dateFormat = "MM"
        curDate_Month = curDateMonthFormatter.string(from: Date.init())
        
        let transactions = realm.objects(Transaction.self)
        if transactions.count == 0{
            return (curDate_Year,curDate_Month)
        }
        
        for item in transactions {
            if let a = item.dt {
                //get earliest year and month
                let (year, month) = getYearandMonth(dt: a)
                //print (year+month)
                if year+month < minDate_Year+minDate_Month{
                    minDate_Year = year
                    minDate_Month = month
                }
            }
        }
        
        //print ("mindate: \(minDate_Year)-\(minDate_Month)")
       // print ("curdate: \(curDate_Year)-\(curDate_Month)")
        
        // *** Changes by Chi ****
        if Int(minDate_Year) == nil && Int(curDate_Year) == nil {
            print ("cant get date")
            return ("2018", "12")
        }
        /////////////////////
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
        print("pass in \(year)-\(month)")
        var sum_expense : Double
        var sum_income : Double
        sum_expense = 0.0
        sum_income = 0.0
        
        let transactions = realm.objects(Transaction.self)
        if transactions.count == 0{
            return
        }
        for item in transactions {
            let type = item.type
            let a = item.amount
            if let date = item.dt{
                let (itemYear, itemMonth) = getYearandMonth(dt: date)
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
    
    
    @IBOutlet weak var typeFilterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var accountFilterButton: UIButton!
    @IBOutlet weak var categoryFilterButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    
    @IBAction func pressTypeFilterButton(_ sender: Any) {
        typeFilterDropdown.show()
        typeFilterDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.typeFilterDropdown.selectedItem == "Income" {
                self.typeFilterButton.setTitle(self.typeFilterDropdown.selectedItem!, for: UIControl.State.normal)
                self.categoryFilterDropdown.dataSource = incomeCategories
                self.categoryFilterDropdown.clearSelection()
                self.categoryFilterButton.setTitle("Category", for: UIControl.State.normal)
            }
            if self.typeFilterDropdown.selectedItem == "Expense" {
                self.typeFilterButton.setTitle(self.typeFilterDropdown.selectedItem!, for: UIControl.State.normal)
                self.categoryFilterDropdown.dataSource = categories
                self.categoryFilterDropdown.clearSelection()
                self.categoryFilterButton.setTitle("Category", for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func pressCategoryFilterButton(_ sender: Any) {
        categoryFilterDropdown.show()
        categoryFilterDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.categoryFilterDropdown.selectedItem != nil {
            self.categoryFilterButton.setTitle(self.categoryFilterDropdown.selectedItem!, for: UIControl.State.normal)
            }
        }
    }

    
    @IBAction func pressSortButton(_ sender: Any) {
        sortDropdown.show()
        sortDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.sortDropdown.selectedItem != nil {
            self.sortButton.setTitle(self.sortDropdown.selectedItem!, for: UIControl.State.normal)
            }
        }
    }
    
    
    @IBAction func pressAccountFilterButton(_ sender: Any) {
        accountFilterDropdown.show()
        accountFilterDropdown.selectionAction = { [unowned self] (index: Int, item: String) in if self.accountFilterDropdown.selectedItem != nil {
            self.accountFilterButton.setTitle(self.accountFilterDropdown.selectedItem!, for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func pressFilterButton(_ sender: Any) {
        displayTransactions ()
    }
    
    @IBAction func pressClearButton(_ sender: Any) {
        typeFilterDropdown.clearSelection()
        typeFilterButton.setTitle("All", for: UIControl.State.normal)
        accountFilterDropdown.clearSelection()
        accountFilterButton.setTitle("Account", for: UIControl.State.normal)
        categoryFilterDropdown.clearSelection()
        categoryFilterButton.setTitle("Category", for: UIControl.State.normal)
        sortDropdown.clearSelection()
        sortButton.setTitle("Sort by", for: UIControl.State.normal)
        displayTransactions()
    }
    
    
    
    ////////////////////////
    
    func displayTransactions () {
        var sortCondition : String = ""
        var query : String? = nil
        var type : Bool = true //expense
        
        label1Array.removeAll()
        label2Array.removeAll()
        var label1 : String
        var label2 : String
        var sort_Condition : String
        var ascending_OrNot : Bool
        label1 = ""
        label2 = ""
        
        var year : String
        var month : String
        if let title = self.displayMonthDropDown.title(for: UIControl.State.normal){
            year = title.substring(toIndex: 4)
            month = title.substring(fromIndex: 5)
        }else{
            (year, month) = loadDisplay()
        }
        
        var transactions : Results<Transaction>
        
        if sortDropdown.selectedItem != nil{
            sortCondition = sortDropdown.selectedItem!
        }
        //print(sortCondition)
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
        if typeFilterDropdown.selectedItem == "Income"{
            type = false
            query = "type = \(type)"
        }else if typeFilterDropdown.selectedItem == "Expense"{
            type = true
            query = "type = \(type)"
        }else{
            query = nil
        }
        
        if categoryFilterDropdown.selectedItem == nil && accountFilterDropdown.selectedItem == nil{
            if query == nil{
                transactions = realm.objects(Transaction.self).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
            }else {
                transactions = realm.objects(Transaction.self).filter(query!).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
            }
        }else if categoryFilterDropdown.selectedItem != nil && accountFilterDropdown.selectedItem == nil{
            query = "category = \"\(categoryFilterDropdown.selectedItem!)\""
            transactions = realm.objects(Transaction.self).filter(query!).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
        }else if categoryFilterDropdown.selectedItem == nil && accountFilterDropdown.selectedItem != nil{
            if query == nil{
                query = "account = \"\(accountFilterDropdown.selectedItem!)\""
            }else{
                query = query! + "&& account = \"\(accountFilterDropdown.selectedItem!)\""
            }
            transactions = realm.objects(Transaction.self).filter(query!).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
            
        }else if categoryFilterDropdown.selectedItem != nil && accountFilterDropdown.selectedItem != nil{
            query = "category = \"\(categoryFilterDropdown.selectedItem!)\" && account = \"\(accountFilterDropdown.selectedItem!)\""
            transactions = realm.objects(Transaction.self).filter(query!).sorted(byKeyPath: "\(sort_Condition)", ascending: ascending_OrNot)
        }else{
            print("no match case")
            transactions = realm.objects(Transaction.self)
        }
        
        for item in transactions {
            if let dt = item.dt{
                let (itemYear, itemMonth) = getYearandMonth(dt: dt)
                if itemYear == year && itemMonth == month {
                    label1 = dt + "\n"
                    if item.type == true{
                        label1 = label1 + "expense\n"
                    }else{
                        label1 = label1 + "income\n"
                    }
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
                    self.label1Array.append(label1)
                    self.label2Array.append(label2)
                }
            }

        }
        self.transcriptTalbeView.reloadData()
    }

    /*@IBAction func pressSideMenuButton(_ sender: Any) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func getYearandMonth (dt : String) -> (year : String, month : String){
        //print(dt)
        let year = dt.substring(fromIndex: 6)
        let month = dt.substring(toIndex: 2)
        //let year = sub_string.substring(fromIndex: 3)
        //print ("\(year) - \(month)")

        return (year, month)
    }

}
