//
//  EditEntryViewController.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2019/1/5.
//  Copyright © 2019年 Team_927. All rights reserved.
//

import UIKit
import RealmSwift
import FuzzyMatchingSwift
import TesseractOCR
import DatePickerDialog
import SearchTextField
import DropDown
import Dropper
import SwiftEntryKit

// Entry to be edited
var transactionToBeEdited: Transaction = Transaction()

class EditEntryViewController: UIViewController {
    // Realm db
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 2
    ))
    
    // Dropdown lists for account and category
    private var accountDropDown = DropDown()
    private var categoryDropDown = DropDown()
    
    // Outlets
    @IBOutlet weak var typeSeg: UISegmentedControl!
    @IBOutlet weak var amountTextField: SearchTextField!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var locationTextField: SearchTextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print realm db file path
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "NA")
        
        // Dropdown lists for account and category
        accountDropDown.anchorView = accountButton
        accountDropDown.direction = .bottom
        accountDropDown.dataSource = accounts
        accountDropDown.selectionAction = { [unowned self] (index: Int, item: String) in if self.accountDropDown.selectedItem != nil {
            self.accountButton.setTitle(self.accountDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        categoryDropDown.anchorView = categoryButton
        categoryDropDown.direction = .bottom
        categoryDropDown.dataSource = categories
        categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in if self.categoryDropDown.selectedItem != nil {
            self.categoryButton.setTitle(self.categoryDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        // Set initial values to those of the entry to be edited
        if transactionToBeEdited.type == EXPENSE {
            typeSeg.selectedSegmentIndex = 0
        }
        else {
            typeSeg.selectedSegmentIndex = 1
        }
        amountTextField.text = transactionToBeEdited.amountStr
        if transactionToBeEdited.account != nil {
            accountButton.setTitle(transactionToBeEdited.account!, for: .normal)
        }
        if transactionToBeEdited.category != nil {
            categoryButton.setTitle(transactionToBeEdited.category!, for: .normal)
        }
        if transactionToBeEdited.location != nil {
            locationTextField.text = transactionToBeEdited.location!
        }
        if transactionToBeEdited.dt != nil {
            dateButton.setTitle(transactionToBeEdited.dt!, for: .normal)
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            dateButton.setTitle(formatter.string(from: Date()), for: .normal)
        }
        if transactionToBeEdited.text != nil {
            descriptionTextField.text = transactionToBeEdited.text!
        }
    }
    
    
    @IBAction func TypeChanged(_ sender: Any) {
        if typeSeg.selectedSegmentIndex == 0 {
            categoryDropDown.dataSource = categories
        }
        else {
            categoryDropDown.dataSource = incomeCategories
        }
    }
    
    
    @IBAction func AmountChanged(_ sender: Any) {
        // Give suggestions only if entered amount is valid double
        if let amount = Double(amountTextField.text!) {
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
            amountTextField.filterStrings(amountStrings)
        } else {
            return
        }
    }
    @IBAction func AmountEditingEnd(_ sender: Any) {
    }
    
    
    @IBAction func ShowAccounts(_ sender: Any) {
        accountDropDown.show()
    }
    
    
    @IBAction func ShowCategories(_ sender: Any) {
        categoryDropDown.show()
    }
    
    
    @IBAction func LocationChanged(_ sender: Any) {
        let location: String? = locationTextField.text
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
            locationTextField.filterStrings(locationStrings)
        }
        else {
            return
        }
    }
    @IBAction func LocationEditingEnd(_ sender: Any) {
    }
    
    
    @IBAction func DateClicked(_ sender: Any) {
        DatePickerDialog().show("Select Date", doneButtonTitle: "OK", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.dateButton.setTitle(formatter.string(from: dt), for: [])
            }
        }
    }
    
    
    @IBAction func ChangeConfirmed(_ sender: Any) {
        do {
            try
                realm.write {
                    // Validate amount
                    if amountTextField.text == nil {
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
                        let test: Double? = Double(amountTextField.text!)
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
                            transactionToBeEdited.amount = test!
                        }
                    }
                    
                    transactionToBeEdited.type = (typeSeg.selectedSegmentIndex == 0) ? EXPENSE : INCOME
                    transactionToBeEdited.account = accountButton.title(for: .normal)
                    transactionToBeEdited.category = categoryButton.title(for: .normal)
                    transactionToBeEdited.location = locationTextField.text
                    transactionToBeEdited.dt = dateButton.title(for: .normal)
                    transactionToBeEdited.text = descriptionTextField.text
                    transactionToBeEdited.amountStr = String(transactionToBeEdited.amount)
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
        
        // Success message
        ShowSuccessMessage(text: "The entry has been updated.")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func ChangeCanceled(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
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
