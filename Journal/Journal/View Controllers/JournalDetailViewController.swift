//
//  JournalDetailViewController.swift
//  Journal
//
//  Created by Alex Rhodes on 9/16/19.
//  Copyright © 2019 Alex Rhodes. All rights reserved.
//

import UIKit
import CoreData

class JournalDetailViewController: UIViewController {
    
    var journal: Journal?
    
    var journalController: JournalController?
    
    @IBOutlet weak var moodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
    }
    
    func setViews() {
        
        title = journal?.title ?? ""
        
        if let moodString = journal?.mood,
            let mood = Mood(rawValue: moodString) {
            
            let index = Mood.allCases.firstIndex(of: mood) ?? 0
            
            moodSegmentedControl.selectedSegmentIndex = index
        }
        textField.text = journal?.title
        textView.text = journal?.bodyText
        
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        let timeInterval = TimeInterval(NSDate().timeIntervalSince1970)
        let time   = Date(timeIntervalSince1970: timeInterval)
        
        guard let title = textField.text,
            let body = textView.text else {return}
        
        let index = moodSegmentedControl.selectedSegmentIndex
        let mood = Mood.allCases[index]
        
        if let journal = journal {
            journalController?.updateJournal(journal: journal, with: title, bodyText: body, time: time, mood: mood)
        } else {
            journalController?.createJournal(with: title, bodyText: body, mood: mood)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
