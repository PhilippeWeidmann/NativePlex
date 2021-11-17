//
//  CodeResponse.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 24.06.21.
//

import Foundation

class CodeResponse: Codable {
    let id: Int
    let code: String
    let authToken: String?
}
