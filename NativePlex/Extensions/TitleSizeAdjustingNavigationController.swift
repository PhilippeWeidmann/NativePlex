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

/// A `UINavigationController` that adjusts the font size of its large title labels to fit its content
open class TitleSizeAdjustingNavigationController: UINavigationController {
    var minimumScaleFactor: CGFloat = 0.5

    #if !os(tvOS)
        public override func viewDidLayoutSubviews() {
            guard navigationBar.prefersLargeTitles else { return }

            updateLargeTitleLabels()
        }
    #endif

    private func updateLargeTitleLabels() {
        largeTitleLabels().forEach {
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = minimumScaleFactor
        }
    }

    private func largeTitleLabels() -> [UILabel] {
        let subviews = recursiveSubviews(of: navigationBar)
        let labels = subviews.compactMap { $0 as? UILabel }
        let titles = viewControllers.compactMap { $0.navigationItem.title } + viewControllers.compactMap { $0.title }
        let titleLabels = labels.filter {
            if let text = $0.text, titles.contains(text) {
                return true
            }
            return false
        }
        // 'large' title labels are identified by comparing font size
        let titleLabelFontSizes = titleLabels.map { $0.font.pointSize }
        let largeTitleLabelFontSize = titleLabelFontSizes.max()
        let largeTitleLabels = titleLabels.filter { $0.font.pointSize == largeTitleLabelFontSize }
        return largeTitleLabels
    }

    private func recursiveSubviews(of view: UIView) -> [UIView] {
        var result = [UIView]()
        for subview in view.subviews {
            result.append(subview)
            result.append(contentsOf: recursiveSubviews(of: subview))
        }
        return result
    }

    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

}
