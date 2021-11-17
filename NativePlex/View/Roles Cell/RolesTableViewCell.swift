//
//  SeasonsTableViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 12.06.21.
//

import UIKit

class RolesTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    private var roles = [Role]()

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(cellView: RoleCollectionViewCell.self)
    }

    func configureWith(roles: [Role]) {
        self.roles = roles
        collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDelegate
extension RolesTableViewCell: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDataSource
extension RolesTableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: RoleCollectionViewCell.self, for: indexPath)
        let role = roles[indexPath.row]
        cell.configureWith(role: role)
        return cell
    }

}
