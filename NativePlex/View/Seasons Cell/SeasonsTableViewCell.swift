//
//  SeasonsTableViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 12.06.21.
//

import UIKit

class SeasonsTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: MovieDetailsViewController?
    private var server: Server!
    private var metadatas = [Metadata]()

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(cellView: MovieCollectionViewCell.self)
    }

    func configureWith(server: Server, metadatas: [Metadata]) {
        self.server = server
        self.metadatas = metadatas
        collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDelegate
extension SeasonsTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let metadata = metadatas[indexPath.row]
        delegate?.didSelectSeason(metadata)
    }
}

// MARK: - UICollectionViewDataSource
extension SeasonsTableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metadatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: MovieCollectionViewCell.self, for: indexPath)
        let metadata = metadatas[indexPath.row]
        cell.configureWith(server: server, metadata: metadata)
        return cell
    }

}
