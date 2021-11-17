//
//  LoginViewController.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 25.06.21.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var listeningTimer: Timer?

    private var code: String?
    private var pinId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        activityIndicator.startAnimating()
        ApiFetcher.instance.generateCode { response, _ in
            if let response = response,
               let loginRequestUrl = URL(string: "https://app.plex.tv/auth#?clientID=\(SessionPreferences.shared.userId)&code=\(response.code)&context%5Bdevice%5D%5Bproduct%5D=NativePlex") {
                self.code = response.code
                self.pinId = response.id
                self.webView.load(URLRequest(url: loginRequestUrl))
            }
        }
    }

    func startListeningForCode() {
        guard let pinId = pinId, let code = code else {
            return
        }
        listeningTimer?.invalidate()

        listeningTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            ApiFetcher.instance.getToken(for: pinId, code: code) { response, _ in
                if let token = response?.authToken {
                    self.listeningTimer?.invalidate()
                    SessionPreferences.shared.userToken = token
                    self.navigationController?.dismiss(animated: true)
                    let rootNavigationViewControllers = (self.navigationController?.presentingViewController as? MainSplitViewController)?.viewControllers.compactMap { $0 as? UINavigationController }
                    rootNavigationViewControllers?.flatMap(\.viewControllers).compactMap { $0 as? DirectoriesTableViewController }.first?.reloadData()
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.5) {
            webView.alpha = 1
        }
        startListeningForCode()
    }
}
