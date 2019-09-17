//
//  Jornal+Convenience.swift
//  Journal
//
//  Created by Alex Rhodes on 9/16/19.
//  Copyright © 2019 Alex Rhodes. All rights reserved.
//

import Foundation
import CoreData

enum Mood: String, CaseIterable {
    case 😶
    case 🙂
    case 😎
}

extension Journal {
    
    
    convenience init(title: String, bodyText: String, identifier: String?, time: Date, mood:  Mood, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        self.mood = mood.rawValue
        self.title = title
        self.identifier = identifier
        self.bodyText = bodyText
        self.time = time
        
    }
    
    
}
