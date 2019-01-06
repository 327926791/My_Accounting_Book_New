//
//  ViewController.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/11/26.
//  Copyright © 2018年 Team_927. All rights reserved.
//

import UIKit
import RealmSwift
import FuzzyMatchingSwift
import TesseractOCR
import DatePickerDialog
import SearchTextField
import DropDown
import Dropper

class ViewController: UIViewController {
    // Realm db
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 2
    ))
    
    // Dropdown lists for account and category
    private var accountDropDown = DropDown()
    private var categoryDropDown = DropDown()
    
    // Outlets
    @IBOutlet weak var segCtrl_CreateEntry_Type: UISegmentedControl!
    @IBOutlet weak var textField_CreateEntry_Amount: SearchTextField!
    @IBOutlet weak var button_CreateEntry_Account: UIButton!
    @IBOutlet weak var button_CreateEntry_Category: UIButton!
    @IBOutlet weak var textField_CreateEntry_Location: SearchTextField!
    @IBOutlet weak var button_CreateEntry_SelectDate: UIButton!
    @IBOutlet weak var textField_CreateEntry_Description: UITextField!
    @IBOutlet weak var button_CreateEntry_Create: UIButton!
    @IBOutlet weak var button_CreateEntry_SaveAsTemplate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print realm db file path
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "NA")
        
        // Dropdown lists for account and category
        accountDropDown.anchorView = button_CreateEntry_Account
        accountDropDown.direction = .bottom
        accountDropDown.dataSource = accounts
        accountDropDown.selectionAction = { [unowned self] (index: Int, item: String) in if self.accountDropDown.selectedItem != nil {
            self.button_CreateEntry_Account.setTitle(self.accountDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        categoryDropDown.anchorView = button_CreateEntry_Category
        categoryDropDown.direction = .bottom
        categoryDropDown.dataSource = categories
        categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in if self.categoryDropDown.selectedItem != nil {
            self.button_CreateEntry_Category.setTitle(self.categoryDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        // Set initial date to today
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        button_CreateEntry_SelectDate.setTitle(formatter.string(from: Date()), for: .normal)
    }
    
    // *** CCW ***
    func autoCompleteFromAmount(amountStr: String){
        print(amountStr)
        let amountArray = realm.objects(Transaction.self).filter("amountStr BEGINSWITH '\(amountStr)'").sorted(byKeyPath: "dt", ascending: false)
        if amountArray.count != 0 {
            print(amountArray[0].amount)
            if (amountArray[0].type){
                segCtrl_CreateEntry_Type.selectedSegmentIndex = 1
            }
            else {
                segCtrl_CreateEntry_Type.selectedSegmentIndex = 0
            }
            button_CreateEntry_Account.setTitle(amountArray[0].account!, for: .normal)
            button_CreateEntry_Category.setTitle(amountArray[0].category!, for: .normal)
            if (amountArray[0].location != nil){
                textField_CreateEntry_Location.text = amountArray[0].location!
            }
            else {
                textField_CreateEntry_Location.text = ""
            }
            if (amountArray[0].text != nil){
                textField_CreateEntry_Description.text = amountArray[0].text!
            }
            else {
                textField_CreateEntry_Description.text = ""
            }
            
            
        }
    }
    
    
    @IBAction func TypeChanged(_ sender: Any) {
        if segCtrl_CreateEntry_Type.selectedSegmentIndex == 0 {
            categoryDropDown.dataSource = categories
        }
        else {
            categoryDropDown.dataSource = incomeCategories
        }
    }
    
    
    @IBAction func textField_CreateEntry_Amount_EditingChanged(_ sender: Any) {
        // Give suggestions only if entered amount is valid double
        if let amount = Double(textField_CreateEntry_Amount.text!) {
            let amountStr: String = textField_CreateEntry_Amount.text!
            autoCompleteFromAmount(amountStr: amountStr)
            // Most recently used amount first
            let transactions = realm.objects(Transaction.self).filter("amount >= \(amount)").sorted(byKeyPath: "dt", ascending: false)
            var amountStrings = [String]()
            // At most 5 suggestions
            // No duplicate
            var count = 0
            for transaction in transactions {
                let str = String(format:"%f", transaction.amount)
                if (amountStrings.contains(str)) {
                    continue
                }
                amountStrings.append(str)
                if count < 5 {
                    count += 1
                }
                else {
                    break
                }
            }
            // Contents for suggestion dropdown list
            textField_CreateEntry_Amount.filterStrings(amountStrings)
        } else {
            return
        }
    }
    @IBAction func textField_CreateEntry_Amount_EditingDidEnd(_ sender: Any) {
    }
    
    
    @IBAction func ShowAccounts(_ sender: Any) {
        accountDropDown.show()
    }
    
    
    @IBAction func ShowCategories(_ sender: Any) {
        categoryDropDown.show()
    }
    
    
    @IBAction func textField_CreateEntry_Locations_EditingChanged(_ sender: Any) {
        let location: String? = textField_CreateEntry_Location.text
        if (location != nil) {
            // TODO: names with "'"
            let transactions = realm.objects(Transaction.self).filter("location BEGINSWITH[c] '\(location!)'").sorted(byKeyPath: "dt", ascending: false)
            var locationStrings = [String]()
            var count = 0
            for transaction in transactions {
                if (locationStrings.contains(transaction.location!)) {
                    continue
                }
                locationStrings.append(transaction.location!)
                if count < 5 {
                    count += 1
                }
                else {
                    break
                }
            }
            textField_CreateEntry_Location.filterStrings(locationStrings)
        }
        else {
            return
        }
    }
    @IBAction func textField_CreateEntry_Location_EditingDidEnd(_ sender: Any) {
    }
    
    
    @IBAction func button_CreateEntry_SelectDate_TouchUpInside(_ sender: Any) {
        DatePickerDialog().show("Select Date", doneButtonTitle: "OK", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.button_CreateEntry_SelectDate.setTitle(formatter.string(from: dt), for: [])
            }
        }
    }
    
    
    @IBAction func button_CreateEntry_Create_TouchUpInside(_ sender: Any) {
        let t = Transaction()
        
        // Validate amount
        if textField_CreateEntry_Amount.text == nil {
            let alert = UIAlertController(title: "Error", message: "Please enter the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        else {
            let test: Double? = Double(textField_CreateEntry_Amount.text!)
            if test == nil {
                let alert = UIAlertController(title: "Error", message: "The amount is invalid.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else if test! < 0 {
                let alert = UIAlertController(title: "Error", message: "The amount should be no less than than 0.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else {
                t.amount = test!
            }
        }
        
        t.type = (segCtrl_CreateEntry_Type.selectedSegmentIndex == 0) ? EXPENSE : INCOME
        t.account = button_CreateEntry_Account.title(for: .normal)
        t.category = button_CreateEntry_Category.title(for: .normal)
        t.location = textField_CreateEntry_Location.text
        t.dt = button_CreateEntry_SelectDate.title(for: .normal)
        t.text = textField_CreateEntry_Description.text
        t.amountStr = String(t.amount)
        
        do {
            try
            realm.write {
                realm.add(t)
            }
        }
        catch {
            let alert = UIAlertController(title: "Error", message: "\(error) Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Success", message: "The entry has been created.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func button_CreateEntry_SaveAsTemplate_TouchUpInside(_ sender: Any) {
        // Validate amount
        let amount_ : Double
        if self.textField_CreateEntry_Amount.text == nil {
            let alert = UIAlertController(title: "Error", message: "Please enter the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        else {
            let test: Double? = Double(self.textField_CreateEntry_Amount.text!)
            if test == nil {
                let alert = UIAlertController(title: "Error", message: "The amount is invalid.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else if test! < 0 {
                let alert = UIAlertController(title: "Error", message: "The amount should be no less than than 0.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else {
                amount_ = test!
            }
        }
        
        // Empty name alert
        let emptyNameAlert = UIAlertController(title: "Error", message: "Please give the template a valid name.", preferredStyle: .alert)
        emptyNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        
        // Duplicate name alert
        let duplicateNameAlert = UIAlertController(title: "Error", message: "A template with the same name already exists. Please give the new template a different name.", preferredStyle: .alert)
        duplicateNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        
        // Ask for template name and add template to db
        showInputDialog(title: "Save as Template",
                        subtitle: "Please give a name to the template:",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: nil,
                        inputKeyboardType: .default)
        { (input:String?) in
            let t = TransactionTemplate()
            let tempName = input
            if tempName == nil || tempName!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.present(emptyNameAlert, animated: true, completion: nil)
                return
            }
            let instances = self.realm.objects(TransactionTemplate.self).filter("name = '\(tempName!.trimmingCharacters(in: .whitespacesAndNewlines))'")
            if instances.count > 0 {
                self.present(duplicateNameAlert, animated: true, completion: nil)
                return
            }
            t.name = tempName!
            t.amount = amount_
            t.type = (self.segCtrl_CreateEntry_Type.selectedSegmentIndex == 0) ? EXPENSE : INCOME
            t.account = self.button_CreateEntry_Account.title(for: .normal)
            t.category = self.button_CreateEntry_Category.title(for: .normal)
            t.location = self.textField_CreateEntry_Location.text
            t.text = self.textField_CreateEntry_Description.text
            t.amountStr = String(t.amount)
            
            do {
                try
                    self.realm.write {
                        self.realm.add(t)
                }
            }
            catch {
                let alert = UIAlertController(title: "Error", message: "\(error) Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let successAlert = UIAlertController(title: "Success", message: "The template \"\(t.name)\" has been created.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(successAlert, animated: true, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
