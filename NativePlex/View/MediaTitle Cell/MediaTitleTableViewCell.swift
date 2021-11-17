//
//  MoveTitleTableViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 11.06.21.
//

import UIKit

class MediaTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    func configureGradient(bounds: CGRect) {
        let gradient = CAGradientLayer()

        gradient.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: gradientView.frame.height))
        gradient.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(1).cgColor]

        gradientView.layer.insertSublayer(gradient, at: 0)
    }

}
