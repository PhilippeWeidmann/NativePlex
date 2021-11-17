//
//  EpisodeCollectionViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 14.06.21.
//

import UIKit
import Nuke

class EpisodeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var episodePreviewContentView: UIView!
    @IBOutlet weak var episodePreviewImageView: UIImageView!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        episodePreviewContentView.addShadow(elevation: 4)
        episodePreviewImageView.cornerRadius = 15
        episodePreviewContentView.roundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 15)
    }

    func configureWith(server: Server, episode: Metadata) {
        episodeTitleLabel.text = episode.title
        if let index = episode.index {
            episodeNumberLabel.text = "Episode \(index)"
        }

        if let imagePath = episode.thumb,
            let request = ApiFetcher.instance.urlRequestFor(server: server, imagePath: imagePath) {
            Nuke.loadImage(with: request, into: episodePreviewImageView) { [self] result in
                switch result {
                case .success(_):
                    episodePreviewImageView.contentMode = .scaleToFill
                case .failure(_):
                    episodePreviewImageView.image = UIImage(systemName: "photo")
                    episodePreviewImageView.contentMode = .scaleAspectFit
                }
            }
        }
    }

}
