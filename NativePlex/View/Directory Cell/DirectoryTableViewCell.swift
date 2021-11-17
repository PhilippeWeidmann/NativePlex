//
//  DirectoryTableViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 11.06.21.
//

import UIKit

class DirectoryTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedView.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedView.isHidden = !selected
    }

}
