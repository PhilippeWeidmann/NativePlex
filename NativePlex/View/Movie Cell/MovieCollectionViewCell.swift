//
//  MovieCollectionViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 09.06.21.
//

import UIKit
import Nuke

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieArtContentView: UIView!
    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        movieArtContentView.addShadow(elevation: 4)
        artImageView.cornerRadius = 15
        movieArtContentView.roundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 15)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artImageView.image = UIImage(systemName: "photo")
        artImageView.contentMode = .scaleAspectFit
        titleLabel.text = nil
        yearLabel.text = nil
    }

    func configureWith(server: Server, metadata: Metadata) {
        titleLabel.text = metadata.title

        if let imagePath = metadata.thumb,
            let request = ApiFetcher.instance.urlRequestFor(server: server, imagePath: imagePath) {
            Nuke.loadImage(with: request, into: artImageView) { [self] result in
                switch result {
                case .success(_):
                    artImageView.contentMode = .scaleToFill
                case .failure(_):
                    artImageView.image = UIImage(systemName: "photo")
                    artImageView.contentMode = .scaleAspectFit
                }
            }
        }

        switch metadata.type {
        case .photo:
            if let year = metadata.year {
                yearLabel.text = "\(year)"
            }
        case .movie:
            if let year = metadata.year {
                yearLabel.text = "\(year)"
            }
        case .show:
            if let seasonCount = metadata.childCount {
                yearLabel.text = "\(seasonCount) seasons"
            }
        case .season:
            if let episodeCount = metadata.leafCount {
                yearLabel.text = "\(episodeCount) episodes"
            }
        case .episode:
            if let episodeCount = metadata.childCount {
                yearLabel.text = "\(episodeCount) episodes"
            }
        case .none:
            break
        }
    }

}
