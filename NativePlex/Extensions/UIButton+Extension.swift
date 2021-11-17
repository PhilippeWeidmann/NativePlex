/*
Infomaniak Core - iOS
Copyright (C) 2021 Infomaniak Network SA

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import UIKit

public extension UIButton {
    func setLoading(_ loading: Bool, style: UIActivityIndicatorView.Style = .medium) {
        self.isEnabled = !loading
        if loading {
            self.setTitle("", for: .disabled)
            let loadingSpinner = UIActivityIndicatorView(style: style)
            loadingSpinner.startAnimating()
            loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
            loadingSpinner.hidesWhenStopped = true
            self.addSubview(loadingSpinner)
            loadingSpinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loadingSpinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        } else {
            self.setTitle(self.title(for: .normal), for: .disabled)
            for view in self.subviews {
                if view.isKind(of: UIActivityIndicatorView.self) {
                    view.removeFromSuperview()
                }
            }
        }
    }
}
