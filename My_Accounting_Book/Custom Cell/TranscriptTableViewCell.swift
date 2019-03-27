//
//  TranscriptTableViewCell.swift
//  My_Accounting_Book
//
//  Created by Yingqian Gu on 2019-01-10.
//  Copyright © 2019 Team_927. All rights reserved.
//

import UIKit

class TranscriptTableViewCell: UITableViewCell {

    @IBOutlet weak var tableCellLabel1: UILabel!
    @IBOutlet weak var tableCellLabel2: UILabel!
    @IBOutlet var blue_view: UIView!
    @IBOutlet var content_view: UIView!
    var id : String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.blue_view.layer.cornerRadius = 5
        self.blue_view.layer.masksToBounds = true
        self.blue_view.layer.borderWidth = 1
        self.blue_view.layer.shadowOpacity=0.25
        self.blue_view.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.blue_view.layer.shadowRadius = 3
        //self.blue_view.layer.shadowColor = da
        self.blue_view.layer.masksToBounds = false
        //print("call init func")
        // Initialization code

    }
    
}
