//
//  Media.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 11.06.21.
//

import Foundation

class Media: Codable {

    let id: Int
    let parts: [Part]

    enum CodingKeys: String, CodingKey {
        case id
        case parts = "Part"
    }
}
