//
//  ServerManager.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 24.06.21.
//

import Foundation

class ServerManager {

    static let shared = ServerManager()
    let userId: String

    private init() {
        userId = SessionPreferences.shared.userId
    }

}
