//
//  User.swift
//  Money Management
//
//  Created by Khue on 25/05/2023.
//

import Foundation

struct User: Codable {
    let name: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
    }
    
}
