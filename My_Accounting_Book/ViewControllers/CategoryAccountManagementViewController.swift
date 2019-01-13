//
//  CategoryAccountManagementViewController.swift
//  My_Accounting_Book
//
//  Created by Mike Sun on 2019-01-12.
//  Copyright © 2019 Team_927. All rights reserved.
//

import UIKit
import DropDown
import RealmSwift
import SwiftEntryKit


let targets = ["Category","Account"]
enum targetFlagEnum{
    case Category
    case Account
}

class CategoryAccountManagementViewController: UIViewController {

    private var targetDropDown = DropDown()
    private var targetFlag = targetFlagEnum.Category
    private var selectionIndexTracker: [Int] = Array()
    
    @IBOutlet weak var chooseTargetButton: UIButton!
    @IBAction func chooseTargetButtonPressed(_ sender: Any) {
        targetDropDown.show()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New \(targetFlag)", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // gets triggered after click the "Add Item"
            
            let trimmedString = textField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
            if trimmedString.isEmpty{
                let alert = UIAlertController(title: "Error", message: "Please provide input.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if self.targetFlag == targetFlagEnum.Category{
                userDefaultCategories.append(trimmedString)
                UserDefaults.standard.set(userDefaultCategories, forKey: "categories")
            }else{
                userDefaultAccounts.append(trimmedString)
                UserDefaults.standard.set(userDefaultAccounts, forKey: "accounts")
            }
            
            self.tableView.reloadData()
            self.ShowSuccessMessage(text: "Addition Successful")
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func renameButtonPressed(_ sender: Any) {
        if selectionIndexTracker.count != 1{
            let alert = UIAlertController(title: "Error", message: "Select Only One Entry.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var textField = UITextField()
        var entryToRename: String = ""
        if targetFlag == targetFlagEnum.Category{
            entryToRename = userDefaultCategories[selectionIndexTracker[0]]
        }else{
            entryToRename = userDefaultAccounts[selectionIndexTracker[0]]
        }
        
        let alert = UIAlertController(title: "Rename \(entryToRename)", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Rename", style: .default) { (action) in
            // gets triggered after click the "Add Item"
            
            let trimmedString = textField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
            if trimmedString.isEmpty{
                let alert = UIAlertController(title: "Error", message: "Please provide input.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if self.targetFlag == targetFlagEnum.Category{
                userDefaultCategories[self.selectionIndexTracker[0]] = trimmedString
                UserDefaults.standard.set(userDefaultCategories, forKey: "categories")
            }else{
                userDefaultAccounts[self.selectionIndexTracker[0]] = trimmedString
                UserDefaults.standard.set(userDefaultAccounts, forKey: "accounts")
            }
            
            // clears checkmark
            self.selectionIndexTracker.removeAll()
            
            self.tableView.reloadData()
            
            
            
            
            // update database
            let realm = try! Realm()
            let data = realm.objects(Transaction.self)
            
            for item in data{
                if self.targetFlag == targetFlagEnum.Category{
                    if item.category == entryToRename{
                        try! realm.write {
                            item.category = trimmedString
                        }
                    }
                }else{
                    if item.account == entryToRename{
                        try! realm.write {
                            item.account = trimmedString
                        }
                    }
                }
            }
            
            self.ShowSuccessMessage(text: "Renaming Successful")
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        

        if (targetFlag == targetFlagEnum.Category && userDefaultCategories.count == 0) ||
            (targetFlag == targetFlagEnum.Account && userDefaultAccounts.count == 0){
            let alert = UIAlertController(title: "Error", message: "No Entries To Delete.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }else if selectionIndexTracker.count == 0{
            let alert = UIAlertController(title: "Error", message: "Select Entry(s).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        
        // reverse sort index, ease for deletion
        selectionIndexTracker = selectionIndexTracker.sorted{
            $0 > $1
        }
        
        for index in selectionIndexTracker{
            if targetFlag == targetFlagEnum.Category{
                userDefaultCategories.remove(at: index)
            }else{
                userDefaultAccounts.remove(at: index)
            }
        }
        
        if targetFlag == targetFlagEnum.Category{
            UserDefaults.standard.set(userDefaultCategories, forKey: "categories")
        }else{
            UserDefaults.standard.set(userDefaultAccounts, forKey: "accounts")
        }
        
        selectionIndexTracker.removeAll()
        
        tableView.reloadData()
        
        ShowSuccessMessage(text: "Deletion Successful")
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // limit tableview to only show the number of rows with data
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        // Dropdown lists for modification target (category or account, default Category)
        targetDropDown.anchorView = chooseTargetButton
        targetDropDown.direction = .bottom
        targetDropDown.dataSource = targets
        targetDropDown.selectionAction = { [unowned self] (index: Int, item: String) in if self.targetDropDown.selectedItem != nil {
            self.chooseTargetButton.setTitle(self.targetDropDown.selectedItem!, for: UIControl.State.normal)
            
            if self.targetDropDown.selectedItem != "\(self.targetFlag)"{
                self.selectionIndexTracker.removeAll()
            }
            
            
            
            if self.targetDropDown.selectedItem == targets[0]{
                self.targetFlag = targetFlagEnum.Category
            }else{
                self.targetFlag = targetFlagEnum.Account
            }
            self.tableView.reloadData()
            }
        }
        
        
        
        
        
        
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


extension CategoryAccountManagementViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if targetFlag == targetFlagEnum.Category{
            return userDefaultCategories.count
        }else{
            return userDefaultAccounts.count
        }
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if targetFlag == targetFlagEnum.Category{
            cell.textLabel?.text = userDefaultCategories[indexPath.row]
        }else{
            cell.textLabel?.text = userDefaultAccounts[indexPath.row]
        }
        
        // this avoids checkmark carry over when switching between Category and Account
        if selectionIndexTracker.contains(indexPath.row){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            selectionIndexTracker = selectionIndexTracker.filter{
                $0 != indexPath.row
            }
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            if !selectionIndexTracker.contains(indexPath.row){
                selectionIndexTracker.append(indexPath.row)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
  
    
    
}






