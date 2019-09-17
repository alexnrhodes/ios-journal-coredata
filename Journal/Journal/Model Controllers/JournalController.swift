//
//  JournalController.swift
//  Journal
//
//  Created by Alex Rhodes on 9/16/19.
//  Copyright © 2019 Alex Rhodes. All rights reserved.
//

import Foundation
import CoreData

class JournalController {
    
    
    @discardableResult func createJournal(with title: String, bodyText: String, identifier: String?, time: Date, mood: Mood) -> Journal {
    
        let entry = Journal(title: title, bodyText: bodyText, identifier: identifier, time: time, mood: mood, context: CoreDataStack.shared.mainContext)
        
        CoreDataStack.shared.saveToPersistentStore()
        
        return entry
    
    }
    
    func updateTask(journal: Journal, with title: String, bodyText: String?, identifier: String, time: Date, mood: Mood) {
        
        journal.title = title
        journal.bodyText = bodyText
        journal.identifier = identifier
        journal.mood = mood.rawValue
        
        
        CoreDataStack.shared.saveToPersistentStore()
    }
    
    func delete(journal: Journal){
        
        CoreDataStack.shared.mainContext.delete(journal)
        CoreDataStack.shared.saveToPersistentStore()
        
    }
    
}
