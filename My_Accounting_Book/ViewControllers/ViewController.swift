//
//  ViewController.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/11/26.
//  Copyright © 2018年 Team_927. All rights reserved.
//

import UIKit
import RealmSwift
import DropDown
import FuzzyMatchingSwift
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate {
    private var amount_: Double = 0
    
    // Realm db
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 1
    ))
    
    // Suggestion Tries
    private var trieLocations = SuggestionTrie(trieType: LOCATION_TRIE)
    private var trieAmount = SuggestionTrie(trieType: AMOUNT_TRIE)
    
    // Suggestion popovers
    private var locationSuggestions: [LCTuple<Int>] = []
    func setupLocationPopover(for sender: UIView) {
        let locationPopover = LCPopover<Int>(for: sender, title: "Suggested Locations") { tuple in
            guard let value = tuple?.value else { return }
            self.textField_CreateEntry_Location.text = value
        }
        locationPopover.dataList = locationSuggestions
        present(locationPopover, animated: true, completion: nil)
    }
    private var amountSuggestions: [LCTuple<Int>] = []
    func setupAmountPopover(for sender: UIView) {
        let amountPopover = LCPopover<Int>(for: sender, title: "Suggested Amount") { tuple in
            guard let value = tuple?.value else { return }
            self.textField_CreateEntry_Amount.text = value
        }
        amountPopover.dataList = amountSuggestions
        present(amountPopover, animated: true, completion: nil)
    }
    
    // Account dropdown
    private var accountDropDown = DropDown()
    
    // Category dropdown
    private var categoryDropDown = DropDown()
    
    func progressImageRecognition(for tesseract: G8Tesseract) {
        print("Recognition Progress: \(tesseract.progress) %")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print realm db file path
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "NA")
        
        // Init account dropdown
        accountDropDown.anchorView = button_CreateEntry_Account
        accountDropDown.direction = .bottom
        accountDropDown.dataSource = accounts
        accountDropDown.cancelAction = { [unowned self] in
            if self.accountDropDown.selectedItem != nil {
                self.button_CreateEntry_Account.setTitle(self.accountDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        // Init category dropdown
        categoryDropDown.anchorView = button_CreateEntry_Category
        categoryDropDown.direction = .bottom
        categoryDropDown.dataSource = categories
        categoryDropDown.cancelAction = { [unowned self] in
            if self.categoryDropDown.selectedItem != nil {
                self.button_CreateEntry_Category.setTitle(self.categoryDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        // Init suggestion tries
        let transactions = realm.objects(Transaction.self)
        for t in transactions {
            let l = t.location
            if l != nil {
                trieLocations.insert(word: l!)
            }
            
            let a = t.amount
            trieAmount.insert(word: String(a))
        }
    }
    
    @IBOutlet weak var segCtrl_CreateEntry_Type: UISegmentedControl!
    
    @IBOutlet weak var textField_CreateEntry_Amount: UITextField!
    @IBAction func textField_CreateEntry_Amount_EditingChanged(_ sender: Any) {
        let text = textField_CreateEntry_Amount.text
        if text == nil {
            return
        }
        
        dismiss(animated: true, completion: nil)
        
        amountSuggestions.removeAll()
        
        var amounts = [WordAndCount]()
        let fuzzyNeeded = !trieAmount.retrieve(prefix: text!, words: &amounts)
        var count = 0
        if (!fuzzyNeeded) {
            amounts.sort(by: { $0.count > $1.count })
            
            for i in amounts {
                if count == 5 {
                    break
                }
                amountSuggestions.append((key: count, value: i.word))
                count += 1
            }
        }
        else {
            var amountsStr = [String]()
            for i in amounts {
                amountsStr.append(i.word)
            }
            amountsStr = amountsStr.sortedByFuzzyMatchPattern(text!)
            
            for i in amountsStr {
                if count == 5 {
                    break
                }
                amountSuggestions.append((key: count, value: i))
                count += 1
            }
        }
        
        if (count > 0) {
            setupAmountPopover(for: textField_CreateEntry_Amount)
        }
    }
    
    @IBAction func textField_CreateEntry_Amount_EditingDidEnd(_ sender: Any) {
        if textField_CreateEntry_Amount.text == nil {
            amount_ = 0
            textField_CreateEntry_Amount.text = "0"
        }
        else {
            let test:Double? = Double(textField_CreateEntry_Amount.text!)
            if test == nil {
                amount_ = 0
                textField_CreateEntry_Amount.text = "0"
                let alert = UIAlertController(title: "Warning", message: "Entered value is invalid.", preferredStyle: .alert)
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
                let alert = UIAlertController(title: "Warning", message: "The value should be no less than than 0.", preferredStyle: .alert)
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
    
    @IBOutlet weak var button_CreateEntry_Account: UIButton!
    @IBAction func button_CreateEntry_Account_TouchUpInside(_ sender: Any) {
        accountDropDown.show()
        if self.accountDropDown.selectedItem != nil {
            self.button_CreateEntry_Account.setTitle(self.accountDropDown.selectedItem!, for: UIControl.State.normal)
        }
    }
    
    @IBOutlet weak var button_CreateEntry_Category: UIButton!
    @IBAction func button_CreateEntry_Category_TouchUpInside(_ sender: Any) {
        categoryDropDown.show()
        if self.categoryDropDown.selectedItem != nil {
            self.button_CreateEntry_Category.setTitle(self.categoryDropDown.selectedItem!, for: UIControl.State.normal)
        }
    }
    
    @IBOutlet weak var textField_CreateEntry_Location: UITextField!
    @IBAction func textField_CreateEntry_Locations_EditingChanged(_ sender: Any) {
        let text = textField_CreateEntry_Location.text
        // To be implemented: when text == nil || text is empty, suggest top counted locations
        if text == nil {
            return
        }
        
        dismiss(animated: true, completion: nil)
        
        locationSuggestions.removeAll()
        
        var locations = [WordAndCount]()
        let fuzzyNeeded = !trieLocations.retrieve(prefix: text!, words: &locations)
        var count = 0
        if (!fuzzyNeeded) {
            locations.sort(by: { $0.count > $1.count })
            
            for i in locations {
                if count == 5 {
                    break
                }
                locationSuggestions.append((key: count, value: i.word))
                count += 1
            }
        }
        else {
            var locationsStr = [String]()
            for i in locations {
                locationsStr.append(i.word)
            }
            locationsStr = locationsStr.sortedByFuzzyMatchPattern(text!)
            
            for i in locationsStr {
                if count == 5 {
                    break
                }
                locationSuggestions.append((key: count, value: i))
                count += 1
            }
        }
        
        if (count > 0) {
            setupLocationPopover(for: textField_CreateEntry_Location)
        }
    }
    @IBAction func textField_CreateEntry_Location_EditingDidEnd(_ sender: Any) {
    }
        
    
    
    @IBOutlet weak var datePicker_CreateEntry_DateTime: UIDatePicker!
    
    @IBOutlet weak var textField_CreateEntry_Description: UITextField!
    
    @IBOutlet weak var button_CreateEntry_Create: UIButton!
    @IBAction func button_CreateEntry_Create_TouchUpInside(_ sender: Any) {
        let t = Transaction()
        t.type = (segCtrl_CreateEntry_Type.selectedSegmentIndex == 0) ? EXPENSE : INCOME
        t.amount = amount_
        t.account = accountDropDown.selectedItem
        t.category = categoryDropDown.selectedItem
        t.location = textField_CreateEntry_Location.text
        t.dt = String(datePicker_CreateEntry_DateTime.date.description)
        t.text = textField_CreateEntry_Description.text
        
        segCtrl_CreateEntry_Type.selectedSegmentIndex = 0
        textField_CreateEntry_Amount.text = nil
        button_CreateEntry_Account.setTitle("Debit Card", for: UIControl.State.normal)
        button_CreateEntry_Category.setTitle("Food and Drink", for: UIControl.State.normal)
        textField_CreateEntry_Location.text = nil
        datePicker_CreateEntry_DateTime.calendar = Calendar.current
        textField_CreateEntry_Description.text = nil
        
        do {
            try
            realm.write {
                realm.add(t)
            }
        }
        catch {
            let alert = UIAlertController(title: "Failure", message: "\(error) Please try again.", preferredStyle: .alert)
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
        
        let l = t.location
        if l != nil {
            trieLocations.insert(word: l!)
        }
        let a = t.amount
        trieAmount.insert(word: String(a))
        
        let alert = UIAlertController(title: "Success", message: "New entry has been created.", preferredStyle: .alert)
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
