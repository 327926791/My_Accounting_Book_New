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
import Material

class StartPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var transcriptTalbeView: UITableView!
    var label1Array : [String] = [String]()
    var label2Array : [String] = [String]()
    var entryID : [String] = [String]()
    //var modify_item : Transaction!
   // var modify_id : String!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return label1Array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTranscriptCell", for: indexPath) as! TranscriptTableViewCell
        cell.tableCellLabel1.text = label1Array[indexPath.row]
        cell.tableCellLabel2.text = label2Array[indexPath.row]
        cell.id = entryID[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //print("id = ", self.entryID)
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete the transaction?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Yes", style: .default, handler: {(action)->Void in
                //print("yes")
                //let selected_row = tableView.indexPathForSelectedRow()
                //var cell : TranscriptTableViewCell
                let cell = tableView.cellForRow(at: indexPath) as! TranscriptTableViewCell
                //self.tableArray.remove(at: indexPath.row)
                self.label1Array.remove(at: indexPath.row)
                self.label2Array.remove(at: indexPath.row)
                self.entryID.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.delete_entry(id: cell.id)
                self.viewDidLoad()
                
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                //print("cancel")
            }
            
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
        }
        
        let modify = UITableViewRowAction(style: .normal, title: "Modify") { (action, indexPath) in
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "modification_view") as! ModifyViewController

            
            let cell = tableView.cellForRow(at: indexPath) as! TranscriptTableViewCell
            let obj = self.realm.objects(Transaction.self)
            for item in obj {
                if item.id == cell.id{
                    nextViewController.id = cell.id
                    nextViewController.obj = item
                   // print(cell.id)
                    //print(item)
                }
            }
            //let nextViewController = storyBoard.instantiateViewController(withIdentifier: "modification_view")
            self.present(nextViewController, animated:true, completion:nil)
            //self.performSegue(withIdentifier: "modification_view", sender: self)// share item at indexPath
        }
        
        modify.backgroundColor = UIColor.gray
        delete.backgroundColor = UIColor.red
        
        
        return [delete, modify]
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> IndexPath{
        return indexPath
    }
    
    func delete_entry(id : String) {
        print("delete entry with id: \(id)")
        //let realm = try! Realm()
        let obj = realm.objects(Transaction.self)
        for item in obj {
            if item.id == id{
                try! realm.write{
                    realm.delete(item)
                }
            }
        }

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
    
        /*
         Check if first launch
         first launch:      store defaults categories and accounts to UserDefaults
         not first launch:  read categories and accounts from UserDefaults
         */
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            // not first launch
            accounts = UserDefaults.standard.stringArray(forKey: "accounts") ?? [String]()
            categories = UserDefaults.standard.stringArray(forKey: "categories") ?? [String]()
            incomeCategories = UserDefaults.standard.stringArray(forKey: "incomeCategories") ?? [String]()
        } else {
            // first launch
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            accounts = ["Cash", "Debit Card", "Credit Card"]
            categories = ["Food and Drink", "Apparel", "Rent", "Loan and Mortgage", "Bill", "Transportation", "Travelling", "Entertainment", "Health and Fitness", "Education", "Grocery", "Shopping", "Gift", "Online Shopping", "Other"]
            incomeCategories = ["Salary and Wage", "Business Profit", "Investment Return", "Bank Interest", "Payment Received", "Other"]
            
            UserDefaults.standard.set(accounts, forKey: "accounts")
            UserDefaults.standard.set(categories, forKey: "categories")
            UserDefaults.standard.set(incomeCategories, forKey: "incomeCategories")
        }
        
        
        
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
        MonthDropdown.dataSource = DropdownButtonDisplay
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
    @IBOutlet weak var displayMonthDropDown: IconButton!
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
            monthlyIncome.text = "Monthly Income: \(sum_income)"
            monthlyExpense.text = "Monthly Expense: \(sum_expense)"
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
    
    
    @IBOutlet weak var typeFilterButton: RaisedButton!
    @IBOutlet weak var sortButton: RaisedButton!
    @IBOutlet weak var accountFilterButton: RaisedButton!
    @IBOutlet weak var categoryFilterButton: RaisedButton!
    @IBOutlet weak var filterButton: FABButton!
    @IBOutlet weak var clearButton: FABButton!
    
    
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
        entryID.removeAll()
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
                    self.entryID.append(item.id)
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

    @IBAction func addEntry(_ sender: Any) {
        let activity = NSUserActivity(activityType: createEntry)
        
        activity.title = "Record your transaction"
        
        activity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
        } else {
            // Fallback on earlier versions
        }
        
        self.userActivity = activity
        self.userActivity?.becomeCurrent()
    }
    
}
