//
//  JournalRepresentation.swift
//  Journal
//
//  Created by Alex Rhodes on 9/18/19.
//  Copyright © 2019 Alex Rhodes. All rights reserved.
//

import Foundation


struct JournalRepresentation: Codable {
    let title: String
    let time: Date
    let mood: String
    let identifier: String
    let bodyText: String
}
