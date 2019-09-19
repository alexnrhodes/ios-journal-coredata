//
//  JournalController.swift
//  Journal
//
//  Created by Alex Rhodes on 9/16/19.
//  Copyright © 2019 Alex Rhodes. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    
    case get = "GET" // read only
    case put = "PUT" // create data
    case post = "POST" // update or replace data
    case delete = "DELETE" // delete data
    
}
enum NetworkError: Error {
    
    case encodingErr
    case responseErr
    case otherErr(Error)
    case noData
    case notDecoded
    case noToken
    case errorUnwrapping
    
}


class JournalController {
    
    let baseURL = URL(string: "https://journal-22d06.firebaseio.com/")!
    
    func put(journal: Journal, completion: @escaping () -> Void = { }) {
        
        let identifier = journal.identifier ?? UUID().uuidString
        journal.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let journalRepresentation = journal.journalRepresentation else {
            NSLog("Task Representation is nil")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(journalRepresentation)
        } catch {
            NSLog("Error encoding task representation: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                NSLog("Error PUTting task: \(error)")
                completion()
                return
            }
            
            completion()
            }.resume()
    }
    
    func fetchTasksFromAPI(completion: @escaping () -> Void = { }) {
        
        // appendingPathComponent adds a /
        // appendingPathExtension add a .
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion()
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let journalReprentations = try decoder.decode([String: JournalRepresentation].self, from: data).map({ $0.value })
                
                self.updateJournal(with: journalReprentations)
            } catch {
                NSLog("Error decoding: \(error)")
            }
            
            }.resume()
    }
    
    func updateJournal(with representations: [JournalRepresentation]) {
        
        
        let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.identifier) })
        
        // [UUID: TaskRepresentation]
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        // Make a mutable copy of the dictionary above
        var tasksToCreate = representationsByID
        
        do {
            let context = CoreDataStack.shared.mainContext
            
            let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
            
            // identifier == \(identifier)
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
            
            // Which of these tasks exist in Core Data already?
            let existingTasks = try context.fetch(fetchRequest)
            
            // Which need to be updated? Which need to be put into Core Data?
            for journal in existingTasks {
                guard let identifier = UUID(uuidString: journal.identifier!),
                    // This gets the task representation that corresponds to the task from Core Data
                    let representation = representationsByID[identifier] else { continue }
                
                journal.title = representation.title
                journal.bodyText = representation.bodyText
                journal.mood = representation.mood
                
                tasksToCreate.removeValue(forKey: identifier)
            }
            
            // Take the tasks that AREN'T in Core Data and create new ones for them.
            for representation in tasksToCreate.values {
               Journal(journalRepresentation: representation, context: context)
            }
            
            CoreDataStack.shared.saveToPersistentStore()
            
        } catch {
            NSLog("Error fetching tasks from persistent store: \(error)")
        }
    }
    
    func deleteEntryFromServer(journal: Journal, completion: @escaping (Error?) -> Void ) {
        
        guard let identifier = journal.identifier else {return}
        
        let requestURL = baseURL
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting task: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    func createJournal(with title: String, bodyText: String, mood: Mood) {
    
        let journal = Journal(title: title, bodyText: bodyText, mood: mood)
        CoreDataStack.shared.saveToPersistentStore()
        put(journal: journal)

    }
    
    func updateJournal(journal: Journal, with title: String, bodyText: String?, time: Date, mood: Mood) {
        
        journal.title = title
        journal.bodyText = bodyText
        journal.mood = mood.rawValue
        put(journal: journal)
        
        CoreDataStack.shared.saveToPersistentStore()
    }
    
    func delete(journal: Journal){
        
        deleteEntryFromServer(journal: journal) { (error) in
            NSLog("Error deleting journal")
        }
        CoreDataStack.shared.mainContext.delete(journal)
        CoreDataStack.shared.saveToPersistentStore()
        
    }
    
}
