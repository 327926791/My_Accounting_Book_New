//
//  File.swift
//  My_Accounting_Book
//
//  Created by Chunwei Cai on 2019-01-15.
//  Copyright © 2019 Team_927. All rights reserved.
//

import Foundation
import UIKit
import Intents
import CoreSpotlight
import MobileCoreServices

public let createEntry = "com.Team-927.My-Accounting-Book-new.addEntry"

/*
public class Entry {
    
    public static func newEntry(thumbnail: UIImage?) -> NSUserActivity {
        let activity = NSUserActivity(activityType: createEntry)
        if #available(iOS 12.0, *) {
            activity.persistentIdentifier =
                NSUserActivityPersistentIdentifier(createEntry)
        } else {
            // Fallback on earlier versions
        }
        
        activity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
        } else {
            // Fallback on earlier versions
        }
        
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        
        activity.title = "Log your transaction"
        attributes.contentDescription = "Just tap here to start creating an entry!"
        attributes.thumbnailData = thumbnail?.jpegData(compressionQuality: 1.0)
        
        if #available(iOS 12.0, *) {
            activity.suggestedInvocationPhrase = "Create entry"
        } else {
            // Fallback on earlier versions
        }
        
        activity.contentAttributeSet = attributes
        
        return activity
    }

}
 */
