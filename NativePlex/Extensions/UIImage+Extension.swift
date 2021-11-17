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

public class ImageUtil {
    internal typealias ImageOrientation = UIImage.Orientation

    public static func cgImageWithCorrectOrientation(_ image: UIImage) -> CGImage {

        if image.imageOrientation == ImageOrientation.up {
            return image.cgImage!
        }

        var transform = CGAffineTransform.identity

        switch image.imageOrientation {
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: .pi / -2.0)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2.0)
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
        default:
            break
        }

        switch image.imageOrientation {
        case .rightMirrored, .leftMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .downMirrored, .upMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        let contextWidth: Int
        let contextHeight: Int

        switch image.imageOrientation {
        case .left, .leftMirrored,
             .right, .rightMirrored:
            contextWidth = (image.cgImage?.height)!
            contextHeight = (image.cgImage?.width)!
        default:
            contextWidth = (image.cgImage?.width)!
            contextHeight = (image.cgImage?.height)!
        }

        let context = CGContext(data: nil, width: contextWidth, height: contextHeight,
            bitsPerComponent: image.cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: image.cgImage!.colorSpace!,
            bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!

        context.concatenate(transform)
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(contextWidth), height: CGFloat(contextHeight)))

        let cgImage = context.makeImage()
        return cgImage!
    }

    public static func drawImageInBounds(_ image: UIImage, bounds: CGRect) -> UIImage? {
        return drawImageWithClosure(size: bounds.size, scale: UIScreen.main.scale) { _, _ -> UIImage? in
            image.draw(in: bounds)

            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return image
        }
    }

    public static func croppedImageWithRect(_ image: UIImage, rect: CGRect) -> UIImage? {
        return drawImageWithClosure(size: rect.size, scale: image.scale) { (size: CGSize, context: CGContext) -> UIImage? in
            let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: image.size.width, height: image.size.height)
            context.clip(to: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
            image.draw(in: drawRect)

            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return image
        }
    }

    public static func drawImageWithClosure(size: CGSize!, scale: CGFloat, closure: @escaping (_ size: CGSize, _ context: CGContext) -> UIImage?) -> UIImage? {

        guard size.width > 0.0 && size.height > 0.0 else {
            print("WARNING: Invalid size requested: \(size.width) x \(size.height) - must not be 0.0 in any dimension")
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("WARNING: Graphics context is nil!")
            return nil
        }

        return closure(size, context)
    }
}

public extension UIImage {
    func resizeImage(size: CGSize) -> UIImage {
        let imgRef = ImageUtil.cgImageWithCorrectOrientation(self)
        let originalWidth = CGFloat(imgRef.width)
        let originalHeight = CGFloat(imgRef.height)
        let widthRatio = size.width / originalWidth
        let heightRatio = size.height / originalHeight

        let scaleRatio = max(heightRatio, widthRatio)

        let resizedImageBounds = CGRect(x: 0, y: 0, width: round(originalWidth * scaleRatio), height: round(originalHeight * scaleRatio))
        let resizedImage = ImageUtil.drawImageInBounds(self, bounds: resizedImageBounds)
        guard resizedImage != nil else {
            return UIImage()
        }

        return ImageUtil.drawImageInBounds(resizedImage!, bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height)) ?? UIImage()
    }

    func maskImageWithRoundedRect(cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor? = UIColor.white) -> UIImage {

        let imgRef = ImageUtil.cgImageWithCorrectOrientation(self)
        let size = CGSize(width: CGFloat(imgRef.width) / self.scale, height: CGFloat(imgRef.height) / self.scale)

        return ImageUtil.drawImageWithClosure(size: size, scale: self.scale) { (size: CGSize, context: CGContext) -> UIImage? in

            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            self.draw(in: rect)

            if borderWidth > 0 && borderColor != nil {
                context.setStrokeColor(borderColor!.cgColor)
                context.setLineWidth(borderWidth)

                let borderRect = CGRect(x: 0, y: 0,
                    width: size.width, height: size.height)

                let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius)
                borderPath.lineWidth = borderWidth * 2
                borderPath.stroke()
            }

            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return image
        } ?? UIImage()
    }

    class func imageFromColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        UIGraphicsBeginImageContext(size)
        image?.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    class func getInitialsPlaceholder(with name: String, size: CGSize = CGSize(width: 40, height: 40), foregroundColor: UIColor = .white, backgroundColor: UIColor) -> UIImage {
        let initials = name.initials
        let defaultFontRatio: CGFloat = 14.0 / 40.0
        let frame = CGRect(origin: .zero, size: size)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: frame.size.width * defaultFontRatio), .foregroundColor: foregroundColor]
        let initialsSize = initials.size(withAttributes: attributes)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: frame.size.width, height: frame.size.height))
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(renderer.format.bounds)
            (initials as NSString).draw(in: CGRect(x: frame.midX - initialsSize.width / 2, y: frame.midY - initialsSize.height / 2, width: initialsSize.width, height: initialsSize.height), withAttributes: attributes)
        }
    }
}
