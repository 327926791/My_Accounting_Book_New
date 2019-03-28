//
//  ModifyViewController.swift
//  My_Accounting_Book
//
//  Created by Yingqian Gu on 2019-03-27.
//  Copyright © 2019 Team_927. All rights reserved.
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
import Material

class ModifyViewController: UIViewController, UITextFieldDelegate {
    var id : String!
    var obj : Transaction!
    @IBOutlet weak var amount_textfield: UISearchTextField!
    
    @IBOutlet weak var type: UISegmentedControl!
    @IBOutlet weak var account_button: UIButton!
    @IBOutlet weak var category_button: UIButton!
    @IBOutlet weak var location: UISearchTextField!
    @IBOutlet weak var date_button: UIButton!
    @IBOutlet weak var description_button: TextField!
    
    @IBOutlet var scroll_view: UIScrollView!
    @IBOutlet var page_view: UIView!
    
    private var accountDropDown = DropDown()
    private var categoryDropDown = DropDown()
    
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 2
    ))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("id = ", id)
        print("obj = ", obj)
        scroll_view = UIScrollView(frame: view.bounds)
        scroll_view.contentSize = page_view.bounds.size
        scroll_view.addSubview(page_view)
        view.addSubview(scroll_view)
        
        //text field init
        amount_textfield.delegate = self
        location.delegate = self
        description_button.delegate = self
        amount_textfield.keyboardType = UIKeyboardType.decimalPad
        
        description_button.text = obj.text
        description_button.placeholder = "Description"
        description_button.isClearIconButtonEnabled = true
        description_button.isPlaceholderUppercasedWhenEditing = true
        description_button.placeholderActiveColor = UIColor.black
        
        location.delegate = self
        location.text = obj.location
        location.placeholder = "Location"
        location.isClearIconButtonEnabled = true
        location.isPlaceholderUppercasedWhenEditing = true
        location.placeholderActiveColor = UIColor.black
        
        amount_textfield.text = String(format:"%f", obj.amount)
        amount_textfield.isClearIconButtonEnabled = true
        amount_textfield.isPlaceholderUppercasedWhenEditing = true
        amount_textfield.placeholderActiveColor = UIColor.black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pageViewTaped))
        page_view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //dropdown button init.
        // Dropdown lists for account and category

        
        accountDropDown.anchorView = account_button
        accountDropDown.direction = .bottom
        accountDropDown.dataSource = accounts
        accountDropDown.selectionAction = { [unowned self] (index: Int, item: String) in if self.accountDropDown.selectedItem != nil {
            self.account_button.setTitle(self.accountDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        categoryDropDown.anchorView = category_button
        categoryDropDown.direction = .bottom
        categoryDropDown.dataSource = categories
        categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in if self.categoryDropDown.selectedItem != nil {
            self.category_button.setTitle(self.categoryDropDown.selectedItem!, for: UIControl.State.normal)
            }
        }
        
        account_button.setTitle(obj.account!, for: .normal)
        category_button.setTitle(obj.category!, for: .normal)
        /////
        if (obj.type == true){
            type.selectedSegmentIndex = 0
        }else{
            type.selectedSegmentIndex = 1
        }

        date_button.setTitle(obj.dt, for: .normal)
        // Do any additional setup after loading the view.
        
        
        
    }
    

    @objc func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scroll_view.contentInset = contentInsets
            self.scroll_view.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                self.scroll_view.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.scroll_view.contentInset = contentInsets
        self.scroll_view.scrollIndicatorInsets = contentInsets
    }
    
    @objc func pageViewTaped(){
        //print("end editting")
        amount_textfield.endEditing(true)
        location.endEditing(true)
        description_button.endEditing(true)
    }
    
    weak var activeField: UITextField?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //button actions
    
    
    
    @IBAction func type_action(_ sender: UISegmentedControl) {
        if type.selectedSegmentIndex == 0 {
            categoryDropDown.dataSource = categories
            if categories.count > 0 {
                self.category_button.setTitle(categories[0], for: UIControl.State.normal)
            }
        }
        else {
            categoryDropDown.dataSource = incomeCategories
            if incomeCategories.count > 0 {
                self.category_button.setTitle(incomeCategories[0], for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func account_tape(_ sender: UIButton) {
        accountDropDown.show()
    }
    @IBAction func category_tape(_ sender: UIButton) {
        categoryDropDown.show()
    }
    
    @IBAction func date_select(_ sender: UIButton) {
        DatePickerDialog().show("Select Date", doneButtonTitle: "OK", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.date_button.setTitle(formatter.string(from: dt), for: [])
            }
        }
    }
    @IBAction func create_button(_ sender: UIButton) {
        let t = Transaction()
        
        // Validate amount
        if amount_textfield.text == nil {
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
            let test: Double? = Double(amount_textfield.text!)
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
        
        t.type = (type.selectedSegmentIndex == 0) ? EXPENSE : INCOME
        t.account = account_button.title(for: .normal)
        t.category = category_button.title(for: .normal)
        t.location = location.text
        t.dt = date_button.title(for: .normal)
        t.text = description_button.text
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
        
        // Success message
        self.ShowSuccessMessage(text: "The entry has been modified.")
        let delete_obj = realm.objects(Transaction.self)
        for x in delete_obj {
            if x.id == id{
                try! realm.write{
                    realm.delete(x)
                }
            }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "navigation")
        self.present(nextViewController, animated:true, completion:nil)
        
        
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
