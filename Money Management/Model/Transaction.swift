//
//  Transaction.swift
//  Money Management
//
//  Created by Khue on 27/05/2023.
//

import Foundation
import FirebaseFirestore

struct Transaction: Codable {
    let id: Int
    var category: Category
    let amount: Int
    let date: Timestamp
    let note: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case category
        case amount
        case date
        case note
    }
}

