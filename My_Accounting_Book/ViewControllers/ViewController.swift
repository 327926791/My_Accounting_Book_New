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
import SwiftEntryKit

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
    @IBOutlet weak var buttonCreateTest: UIButton! // ** test ** long press
    // ** test ** long press
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create db entries
        //let re = RandomEntries()
        //re.GenerateRandomEntries(realm: realm)
        
        // ** test ** long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 1.2
        self.buttonCreateTest.addGestureRecognizer(longPress)
        
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
        
        // Set initial values for account and category
        if accounts.count > 0 {
            self.button_CreateEntry_Account.setTitle(accounts[0], for: UIControl.State.normal)
        }
        if categories.count > 0 {
            self.button_CreateEntry_Category.setTitle(categories[0], for: UIControl.State.normal)
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
            if categories.count > 0 {
                self.button_CreateEntry_Category.setTitle(categories[0], for: UIControl.State.normal)
            }
        }
        else {
            categoryDropDown.dataSource = incomeCategories
            if incomeCategories.count > 0 {
                self.button_CreateEntry_Category.setTitle(incomeCategories[0], for: UIControl.State.normal)
            }
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
        
        // Success message
        self.ShowSuccessMessage(text: "The entry has been created.")
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
                        actionTitle: "OK",
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
            
            // Success message
            self.ShowSuccessMessage(text: "The template \"\(t.name)\" has been created.")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Belows are used by SwiftEntryKit
enum FormStyle {
    case light
    case dark
    
    var imageSuffix: String {
        switch self {
        case .dark:
            return "_light"
        case .light:
            return "_dark"
        }
    }
    
    var title: EKProperty.LabelStyle {
        let font = MainFont.medium.with(size: 16)
        switch self {
        case .dark:
            return .init(font: font, color: .white, alignment: .center)
        case .light:
            return .init(font: font, color: EKColor.Gray.a800, alignment: .center)
        }
    }
    
    var buttonTitle: EKProperty.LabelStyle {
        let font = MainFont.bold.with(size: 16)
        switch self {
        case .dark:
            return .init(font: font, color: .black)
        case .light:
            return .init(font: font, color: .white)
        }
    }
    
    var buttonBackground: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return .red
        }
    }
    
    var placeholder: EKProperty.LabelStyle {
        let font = MainFont.light.with(size: 14)
        switch self {
        case .dark:
            return .init(font: font, color: UIColor(white: 0.8, alpha: 1))
        case .light:
            return .init(font: font, color: UIColor(white: 0.5, alpha: 1))
        }
    }
    
    var text: EKProperty.LabelStyle {
        let font = MainFont.light.with(size: 14)
        switch self {
        case .dark:
            return .init(font: font, color: .white)
        case .light:
            return .init(font: font, color: .black)
        }
    }
    
    var separator: UIColor {
        return .init(white: 0.8784, alpha: 0.6)
    }
}

class FormFieldPresetFactory {
    
    class func template(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let templatePlaceholder = EKProperty.LabelContent(text: "Enter the name of the template.", style: placeholderStyle)
        return .init(keyboardType: .default, placeholder: templatePlaceholder, textStyle: textStyle, leadingImage: nil, bottomBorderColor: separatorColor)
    }
    
    class func email(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let emailPlaceholder = EKProperty.LabelContent(text: "Email Address", style: placeholderStyle)
        return .init(keyboardType: .emailAddress, placeholder: emailPlaceholder, textStyle: textStyle, leadingImage: UIImage(named: "ic_mail" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func fullName(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let fullNamePlaceholder = EKProperty.LabelContent(text: "Full Name", style: placeholderStyle)
        return .init(keyboardType: .namePhonePad, placeholder: fullNamePlaceholder, textStyle: textStyle, leadingImage: UIImage(named: "ic_user" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func mobile(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let mobilePlaceholder = EKProperty.LabelContent(text: "Mobile Phone", style: placeholderStyle)
        return .init(keyboardType: .decimalPad, placeholder: mobilePlaceholder, textStyle: textStyle, leadingImage: UIImage(named: "ic_phone" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func password(placeholderStyle: EKProperty.LabelStyle, textStyle: EKProperty.LabelStyle, separatorColor: UIColor, style: FormStyle) -> EKProperty.TextFieldContent {
        let passwordPlaceholder = EKProperty.LabelContent(text: "Password", style: placeholderStyle)
        return .init(keyboardType: .namePhonePad, placeholder: passwordPlaceholder, textStyle: textStyle, isSecure: true, leadingImage: UIImage(named: "ic_lock" + style.imageSuffix), bottomBorderColor: separatorColor)
    }
    
    class func fields(by set: TextFieldOptionSet, style: FormStyle) -> [EKProperty.TextFieldContent] {
        var array: [EKProperty.TextFieldContent] = []
        let placeholderStyle = style.placeholder
        let textStyle = style.text
        let separatorColor = style.separator
        if set.contains(.template) {
            array.append(template(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.fullName) {
            array.append(fullName(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.mobile) {
            array.append(mobile(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.email) {
            array.append(email(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        if set.contains(.password) {
            array.append(password(placeholderStyle: placeholderStyle, textStyle: textStyle, separatorColor: separatorColor, style: style))
        }
        return array
    }
}

typealias MainFont = Font.HelveticaNeue

enum Font {
    enum HelveticaNeue: String {
        case ultraLightItalic = "UltraLightItalic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
        case ultraLight = "UltraLight"
        case italic = "Italic"
        case light = "Light"
        case thinItalic = "ThinItalic"
        case lightItalic = "LightItalic"
        case bold = "Bold"
        case thin = "Thin"
        case condensedBlack = "CondensedBlack"
        case condensedBold = "CondensedBold"
        case boldItalic = "BoldItalic"
        
        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "HelveticaNeue-\(rawValue)", size: size)!
        }
    }
}

extension UIColor {
    static func by(r: Int, g: Int, b: Int, a: CGFloat = 1) -> UIColor {
        let d = CGFloat(255)
        return UIColor(red: CGFloat(r) / d, green: CGFloat(g) / d, blue: CGFloat(b) / d, alpha: a)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static let darkDefault = UIColor(white: 45.0/255.0, alpha: 1)
    static let grayText = UIColor(white: 160.0/255.0, alpha: 1)
    static let facebookDarkBlue = UIColor.by(r: 59, g: 89, b: 152)
    static let dimmedLightBackground = UIColor(white: 100.0/255.0, alpha: 0.3)
    static let dimmedDarkBackground = UIColor(white: 50.0/255.0, alpha: 0.3)
    static let pinky = UIColor(rgb: 0xE91E63)
    static let amber = UIColor(rgb: 0xFFC107)
    static let satCyan = UIColor(rgb: 0x00BCD4)
    static let darkText = UIColor(rgb: 0x212121)
    static let redish = UIColor(rgb: 0xFF5252)
    static let darkSubText = UIColor(rgb: 0x757575)
    static let greenGrass = UIColor(rgb: 0x4CAF50)
    static let darkChatMessage = UIColor(red: 48, green: 47, blue: 48)
}

struct EKColor {
    struct BlueGray {
        static let c50 = UIColor(rgb: 0xeceff1)
        static let c100 = UIColor(rgb: 0xcfd8dc)
        static let c200 = UIColor(rgb: 0xb0bec5)
        static let c300 = UIColor(rgb: 0x90a4ae)
        static let c400 = UIColor(rgb: 0x78909c)
        static let c500 = UIColor(rgb: 0x607d8b)
        static let c600 = UIColor(rgb: 0x546e7a)
        static let c700 = UIColor(rgb: 0x455a64)
        static let c800 = UIColor(rgb: 0x37474f)
        static let c900 = UIColor(rgb: 0x263238)
    }
    
    struct Netflix {
        static let light = UIColor(rgb: 0x485563)
        static let dark = UIColor(rgb: 0x29323c)
    }
    
    struct Gray {
        static let a800 = UIColor(rgb: 0x424242)
        static let mid = UIColor(rgb: 0x616161)
        static let light = UIColor(white: 230.0/255.0, alpha: 1)
    }
    
    struct Purple {
        static let a300 = UIColor(rgb: 0xba68c8)
        static let a400 = UIColor(rgb: 0xab47bc)
        static let a700 = UIColor(rgb: 0xaa00ff)
        static let deep = UIColor(rgb: 0x673ab7)
    }
    
    struct BlueGradient {
        static let light = UIColor(red: 100, green: 172, blue: 196)
        static let dark = UIColor(red: 27, green: 47, blue: 144)
    }
    
    struct Yellow {
        static let a700 = UIColor(rgb: 0xffd600)
    }
    
    struct Teal {
        static let a700 = UIColor(rgb: 0x00bfa5)
        static let a600 = UIColor(rgb: 0x00897b)
    }
    
    struct Orange {
        static let a50 = UIColor(rgb: 0xfff3e0)
    }
    
    struct LightBlue {
        static let a700 = UIColor(rgb: 0x0091ea)
    }
    
    struct LightPink {
        static let first = UIColor(rgb: 0xff9a9e)
        static let last = UIColor(rgb: 0xfad0c4)
    }
}

struct TextFieldOptionSet: OptionSet {
    let rawValue: Int
    static let fullName = TextFieldOptionSet(rawValue: 1 << 0)
    static let mobile = TextFieldOptionSet(rawValue: 1 << 1)
    static let email = TextFieldOptionSet(rawValue: 1 << 2)
    static let password = TextFieldOptionSet(rawValue: 1 << 3)
    static let template = TextFieldOptionSet(rawValue: 1 << 4)
}

extension UITextField {
    var textFieldContent: EKProperty.TextFieldContent {
        set {
            attributedPlaceholder = NSAttributedString(string: newValue.placeholder.text, attributes: [.font: newValue.placeholder.style.font, .foregroundColor: newValue.placeholder.style.color])
            keyboardType = newValue.keyboardType
            textColor = newValue.textStyle.color
            font = newValue.textStyle.font
            textAlignment = newValue.textStyle.alignment
            isSecureTextEntry = newValue.isSecure
            text = newValue.textContent
        }
        get {
            fatalError("textFieldContent doesn't have a getter")
        }
    }
}
