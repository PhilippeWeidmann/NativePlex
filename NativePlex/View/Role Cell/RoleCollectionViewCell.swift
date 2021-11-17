//
//  RoleCollectionViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 12.06.21.
//

import UIKit
import Nuke

class RoleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roleImageContentView: UIView!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var roleActorLabel: UILabel!
    @IBOutlet weak var roleCharacterNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        roleImageContentView.addShadow(elevation: 4)
        roleImageView.cornerRadius = roleImageContentView.frame.width / 2
        roleImageContentView.roundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: roleImageContentView.frame.width / 2)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        roleImageView.image = UIImage(systemName: "person.fill")
    }

    func configureWith(role: Role) {
        roleActorLabel.text = role.tag
        roleCharacterNameLabel.text = role.role
        if let imagePath = role.thumb,
            var urlComponents = URLComponents(string: imagePath) {
            urlComponents.scheme = "https"
            if let url = urlComponents.url {
                Nuke.loadImage(with: URLRequest(url: url), into: roleImageView) { [self] result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        roleImageView.image = UIImage(systemName: "person.fill")
                    }
                }
            }
        }
    }
}
