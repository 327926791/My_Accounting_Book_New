//
//  TemporaryStartViewController.swift
//  My_Accounting_Book
//
//  Created by Mike Sun on 2019-01-12.
//  Copyright © 2019 Team_927. All rights reserved.
//

import UIKit

class TemporaryStartViewController: UIViewController {

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         Check if first launch
         first launch:      store defaults categories and accounts to UserDefaults
         not first launch:  read categories and accounts from UserDefaults
         */
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            // not first launch
            userDefaultAccounts = UserDefaults.standard.stringArray(forKey: "accounts") ?? [String]()
            userDefaultCategories = UserDefaults.standard.stringArray(forKey: "categories") ?? [String]()
            userDefaultIncomeCategories = UserDefaults.standard.stringArray(forKey: "incomeCategories") ?? [String]()
        } else {
            // first launch
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            userDefaultAccounts = ["Cash", "Debit Card", "Credit Card"]
            userDefaultCategories = ["Food and Drink", "Apparel", "Rent", "Loan and Mortgage", "Bill", "Transportation", "Travelling", "Entertainment", "Health and Fitness", "Education", "Grocery", "Shopping", "Gift", "Online Shopping", "Other"]
            userDefaultIncomeCategories = ["Salary and Wage", "Business Profit", "Investment Return", "Bank Interest", "Payment Received", "Other"]
            
            UserDefaults.standard.set(userDefaultAccounts, forKey: "accounts")
            UserDefaults.standard.set(userDefaultCategories, forKey: "categories")
            UserDefaults.standard.set(userDefaultIncomeCategories, forKey: "incomeCategories")
        }
    }


}
