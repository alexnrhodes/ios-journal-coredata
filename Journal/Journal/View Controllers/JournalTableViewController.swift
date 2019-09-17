//
//  JournalTableViewController.swift
//  Journal
//
//  Created by Alex Rhodes on 9/16/19.
//  Copyright © 2019 Alex Rhodes. All rights reserved.
//

import UIKit
import CoreData

class JournalTableViewController: UITableViewController {
    
    let journalController = JournalController()
    
    lazy var fetch: NSFetchedResultsController<Journal> = {
        
        let request: NSFetchRequest<Journal> = Journal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "mood", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "mood", cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for frc: \(error)")
        }
        
        
        return frc
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetch.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetch.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalCell", for: indexPath)

        let journal = fetch.object(at: indexPath)
        cell.textLabel?.text = journal.title
        
        let formatter = DateFormatter()
        let date = journal.time
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let string = formatter.string(from: date ?? Date())
        cell.detailTextLabel?.text = string

        return cell
    }
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetch.sections?[section] else {return nil}
        return sectionInfo.name
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let journal = fetch.object(at: indexPath)
            journalController.delete(journal: journal)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "JournalDetailSegue" {
            guard let detailVC = segue.destination as? JournalDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            
            detailVC.journal = fetch.object(at: indexPath)
            detailVC.journalController = journalController
        } else if segue.identifier == "CreateJournalSegue" {
            guard let detailVC = segue.destination as? JournalDetailViewController else { return }
            
            detailVC.journalController = journalController
        }
      
    }

}

extension JournalTableViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath,
                let indexPath = indexPath else {return}
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(set, with: .automatic)
        case .delete:
            tableView.deleteSections(set, with: .automatic)
        default:
            return
        }
    }
    
}
