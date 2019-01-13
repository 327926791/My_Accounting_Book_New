//
//  SideMenuViewController.swift
//  My_Accounting_Book
//
//  Created by Yingqian Gu on 2019-01-12.
//  Copyright © 2019 Team_927. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SideMenuViewController: UIViewController {
    
    /*private var realm = try! Realm(configuration: Realm.Configuration(
        schemaVersion: 2
    ))*/

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressClearDatabaseButton(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete all transactions?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .default, handler: {(action)->Void in
            print("yes")
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("cancel")
        }
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
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
