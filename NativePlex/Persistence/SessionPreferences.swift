//
//  Preferences.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 24.06.21.
//

import Foundation
import KeychainAccess

class SessionPreferences {
    static let shared = SessionPreferences()
    private let defaults = UserDefaults.standard
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    private static let userIdKey = "userId"
    private static let userTokenKey = "userTokenKey"

    var userId: String

    var userToken: String? {
        didSet {
            if let userToken = userToken {
                try? keychain.set(userToken, key: SessionPreferences.userTokenKey)
            }
        }
    }

    var userLoggedIn: Bool {
        return userToken != nil
    }

    private init() {
        if let id = defaults.string(forKey: SessionPreferences.userIdKey) {
            userId = id
        } else {
            let uuid = UUID().uuidString
            defaults.set(uuid, forKey: SessionPreferences.userIdKey)
            userId = uuid
        }

        userToken = try? keychain.getString(SessionPreferences.userTokenKey)
    }
}
