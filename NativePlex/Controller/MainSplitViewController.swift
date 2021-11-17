//
//  MainSplitViewController.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 25.06.21.
//

import UIKit

class MainSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !SessionPreferences.shared.userLoggedIn {
            performSegue(withIdentifier: "welcomeSegue", sender: nil)
        }
    }
}
