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

@IBDesignable
open class ImageButton: UIButton {

    @IBInspectable var imageWidth: CGFloat = 0
    @IBInspectable var imageHeight: CGFloat = 0

    open override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.alpha = 0.5
            } else {
                self.alpha = 1.0
            }
        }
    }

    open override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.alpha = 0.5
            } else {
                self.alpha = 1.0
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        var titleSize = CGSize()
        var imageSize = CGSize()
        let contentSize = self.frame.size
        let contentEdgeInsets = self.contentEdgeInsets
        let titleEdgeInsets = self.titleEdgeInsets
        let imageEdgeInsets = self.imageEdgeInsets

        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
            titleSize = titleLabel.frame.size
        }

        if self.imageView != nil {
            imageSize = CGSize(width: imageWidth, height: imageHeight)
        }

        let totalWidth = imageSize.width + titleSize.width + titleEdgeInsets.left + imageEdgeInsets.right
        let offsetLeft = (contentSize.width - totalWidth) / 2.0
        var imageFrame = CGRect(origin: CGPoint(x: offsetLeft, y: 0), size: imageSize)

        imageFrame.origin.y = (contentSize.height - imageSize.height - contentEdgeInsets.top - contentEdgeInsets.bottom - imageEdgeInsets.top - imageEdgeInsets.bottom) / 2.0 + contentEdgeInsets.top + imageEdgeInsets.top
        imageFrame.origin.x = (contentSize.width - imageSize.width - titleSize.width - contentEdgeInsets.left - contentEdgeInsets.right - imageEdgeInsets.left - imageEdgeInsets.right - titleEdgeInsets.left - titleEdgeInsets.right) / 2.0 + contentEdgeInsets.left + titleEdgeInsets.left

        var titleFrame = CGRect(origin: CGPoint(), size: titleSize)

        titleFrame.origin.y = (contentSize.height - titleSize.height - contentEdgeInsets.top - contentEdgeInsets.bottom - titleEdgeInsets.top - titleEdgeInsets.bottom) / 2.0 + contentEdgeInsets.top + titleEdgeInsets.top
        titleFrame.origin.x = imageFrame.origin.x + imageSize.width + imageEdgeInsets.right + titleEdgeInsets.left

        self.imageView?.frame = imageFrame
        self.titleLabel?.frame = titleFrame
    }
}
