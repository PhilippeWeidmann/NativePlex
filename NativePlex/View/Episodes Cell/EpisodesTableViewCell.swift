//
//  EpisodesTableViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 14.06.21.
//

import UIKit

class EpisodesTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    private var episodeMetadatas = [Metadata]()
    private var server: Server!
    weak var delegate: MovieDetailsViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(cellView: EpisodeCollectionViewCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWith(server: Server, episodes: [Metadata]) {
        self.server = server
        episodeMetadatas = episodes
        collectionView.reloadData()
        contentView.layoutIfNeeded()
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: 1)
        collectionView.layoutIfNeeded()

        return CGSize(width: collectionView.collectionViewLayout.collectionViewContentSize.width, height: collectionView.collectionViewLayout.collectionViewContentSize.height + 64)
    }

}

extension EpisodesTableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodeMetadatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: EpisodeCollectionViewCell.self, for: indexPath)
        cell.configureWith(server: server, episode: episodeMetadatas[indexPath.row])
        return cell
    }

}

extension EpisodesTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.playMetadata(episodeMetadatas[indexPath.row])
    }
}

extension EpisodesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 270, height: 230)
    }
}
