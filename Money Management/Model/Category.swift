//
//  Category.swift
//  Money Management
//
//  Created by Khue on 25/05/2023.
//

import Foundation

struct Category: Codable {
    let id: Int
    let name: String
    let kind: Int
    let imageColor: String
    let categoryImageId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case kind
        case imageColor
        case categoryImageId
    }
}
