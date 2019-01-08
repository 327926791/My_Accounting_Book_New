//
//  CreateEntryUsingTemplateViewController.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2019/1/6.
//  Copyright © 2019年 Team_927. All rights reserved.
//

import UIKit
import SearchTextField
import RealmSwift
import SwiftEntryKit

class CreateEntryUsingTemplateViewController: UIViewController {
    // Realm db
    private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 2
    ))
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var nameTextField: SearchTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func TextChanged(_ sender: Any) {
        let text: String? = nameTextField.text
        if (text != nil) {
            // TODO: names with "'"
            let templates = realm.objects(TransactionTemplate.self).filter("name BEGINSWITH '\(text!)'").sorted(byKeyPath: "name", ascending: true)
            var nameStrings = [String]()
            for template in templates {
                if (nameStrings.contains(template.name)) {
                    continue
                }
                nameStrings.append(template.name)
            }
            nameTextField.filterStrings(nameStrings)
        }
        else {
            return
        }
    }
    
    
    @IBAction func Create(_ sender: Any) {
        let templates = realm.objects(TransactionTemplate.self).filter("name == \"\(nameTextField.text!)\"")
        if (templates.count != 1) {
            let alert = UIAlertController(title: "Error", message: "The template \"\(nameTextField.text!)\" does not exist.", preferredStyle: .alert)
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
        let template = templates[0]
        let t = Transaction()
        t.type = template.type
        t.amount = template.amount
        t.amountStr = template.amountStr
        t.account = template.account
        t.category = template.category
        t.location = template.location
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        t.dt = formatter.string(from: Date())
        t.text = template.text
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
        // Success message
        ShowSuccessMessage(text: "The entry has been created.")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func Cancel(_ sender: Any) {
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
