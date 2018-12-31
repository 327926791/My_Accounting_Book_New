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
import iOSDropDown
import Dropper

class ViewController: UIViewController, G8TesseractDelegate {
    private var amount_: Double = 0
    
    // Realm db
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 1
    ))
    
    // Outlets
    @IBOutlet weak var segCtrl_CreateEntry_Type: UISegmentedControl!
    @IBOutlet weak var textField_CreateEntry_Amount: SearchTextField!
    @IBOutlet weak var textField_CreateEntry_Account: DropDown!
    let accountDropper = Dropper(width: 190, height: 200)
    @IBOutlet weak var button_CreateEntry_Account: UIButton!
    @IBAction func AccountDropdown(_ sender: Any) {
        if accountDropper.status == Dropper.Status.hidden {
            accountDropper.items = accounts
            accountDropper.theme = Dropper.Themes.white
            accountDropper.delegate = self
            accountDropper.cornerRadius = 3
            accountDropper.showWithAnimation(0.15, options: Dropper.Alignment.center, button: button_CreateEntry_Account)
        } else {
            accountDropper.hideWithAnimation(0.1)
        }
    }
    @IBOutlet weak var textField_CreateEntry_Category: DropDown!
    @IBOutlet weak var textField_CreateEntry_Location: SearchTextField!
    @IBOutlet weak var button_CreateEntry_SelectDate: UIButton!
    @IBOutlet weak var textField_CreateEntry_Description: UITextField!
    @IBOutlet weak var button_CreateEntry_Create: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print realm db file path
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "NA")
        
        // Selection dropdown lists for account and category
        textField_CreateEntry_Account.text = accounts[0]
        textField_CreateEntry_Account.optionArray = accounts
        textField_CreateEntry_Account.didSelect{(selectedText, index, id) in
            self.textField_CreateEntry_Account.text = selectedText
        }
        textField_CreateEntry_Category.text = categories[0]
        textField_CreateEntry_Category.optionArray = categories
        textField_CreateEntry_Category.didSelect{(selectedText, index, id) in
            self.textField_CreateEntry_Category.text = selectedText
        }
        
        // Suggestion dropdown lists for amount and location
        textField_CreateEntry_Amount.filterStrings(["Red", "Blue", "Yellow"])
        textField_CreateEntry_Location.filterStrings(["Red", "Blue", "Yellow"])
        
        // Set default date to today
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        self.button_CreateEntry_SelectDate.setTitle(formatter.string(from: Date()), for: .normal)
    }
    
    
    @IBAction func textField_CreateEntry_Amount_EditingChanged(_ sender: Any) {
        // Give suggestions only if entered amount is valid double
        if let amount = Double(textField_CreateEntry_Amount.text!) {
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
    // Validate entered amount
    @IBAction func textField_CreateEntry_Amount_EditingDidEnd(_ sender: Any) {
        if textField_CreateEntry_Amount.text == nil {
            amount_ = 0
            textField_CreateEntry_Amount.text = "0"
        }
        else {
            let test: Double? = Double(textField_CreateEntry_Amount.text!)
            if test == nil {
                amount_ = 0
                textField_CreateEntry_Amount.text = "0"
                let alert = UIAlertController(title: "Warning", message: "Entered amount is invalid.", preferredStyle: .alert)
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
            else if test! < 0 {
                amount_ = 0
                textField_CreateEntry_Amount.text = "0"
                let alert = UIAlertController(title: "Warning", message: "The amount should be no less than than 0.", preferredStyle: .alert)
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
            else {
                amount_ = test!
            }
        }
    }
    
    
    @IBAction func textField_CreateEntry_Locations_EditingChanged(_ sender: Any) {
        let location: String? = textField_CreateEntry_Location.text
        if (location != nil) {
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
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
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
        t.type = (segCtrl_CreateEntry_Type.selectedSegmentIndex == 0) ? EXPENSE : INCOME
        t.amount = amount_
        t.account = textField_CreateEntry_Account.text
        t.category = textField_CreateEntry_Category.text
        t.location = textField_CreateEntry_Location.text
        t.dt = button_CreateEntry_SelectDate.title(for: .normal)
        t.text = textField_CreateEntry_Description.text
        
        segCtrl_CreateEntry_Type.selectedSegmentIndex = 0
        textField_CreateEntry_Amount.text = nil
        textField_CreateEntry_Account.text = accounts[0]
        textField_CreateEntry_Category.text = categories[0]
        textField_CreateEntry_Location.text = nil
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        self.button_CreateEntry_SelectDate.setTitle(formatter.string(from: Date()), for: .normal)
        textField_CreateEntry_Description.text = nil
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    
}
