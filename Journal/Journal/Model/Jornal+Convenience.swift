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
            let identifier = identifier?.uuidString,
            let mood = mood else {return nil}
        
        
        return JournalRepresentation(title: title, time: time, mood: mood, identifier: identifier, bodyText: body)
    }
    
    convenience init(title: String, bodyText: String, identifier: UUID = UUID(), time: Date, mood:  Mood, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        self.mood = mood.rawValue
        self.title = title
        self.identifier = identifier
        self.bodyText = bodyText
        self.time = time
        
    }
    
    @discardableResult convenience init?(journalRepresentation: JournalRepresentation, context: NSManagedObjectContext) {
        
        guard let identifier = UUID(uuidString: journalRepresentation.identifier),
            let mood = Mood(rawValue: journalRepresentation.mood) else {return}
        
        self.init(title: journalRepresentation.title, bodyText: journalRepresentation.bodyText, identifier: identifier, time: journalRepresentation.time, mood: mood, context: context)
    }
    
    
}
