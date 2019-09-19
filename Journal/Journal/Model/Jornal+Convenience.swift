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
    
    var journalRepresentation: JournalRepresentation? {
        
        guard let title = title,
            let body = bodyText,
            let time = time,
            let identifier = identifier,
            let mood = mood else {return nil}
        
        
        return JournalRepresentation(title: title, time: time, mood: mood, identifier: identifier, bodyText: body)
    }
    
    convenience init(title: String, bodyText: String, identifier: String = UUID().uuidString, time: Date = Date(), mood:  Mood, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.mood = mood.rawValue
        self.title = title
        self.identifier = identifier
        self.bodyText = bodyText
        self.time = time
        
    }
    
    @discardableResult convenience init?(journalRepresentation: JournalRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let title = journalRepresentation.title
        let body = journalRepresentation.bodyText
        let identifier = journalRepresentation.identifier
        let time = journalRepresentation.time
        
        guard let mood = Mood(rawValue: journalRepresentation.mood) else {return nil}
        
        self.init(title: title, bodyText: body, identifier: identifier, time: time, mood: mood, context: context)
    }
}
