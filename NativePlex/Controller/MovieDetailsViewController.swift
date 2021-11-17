//
//  MovieDetailsViewController.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 09.06.21.
//

import UIKit
import Nuke
import AVKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainArtImageView: UIImageView!

    var server: Server!
    var metadata: Metadata!
    var metadataDetails: Metadata!
    var childrenMetadata: [Metadata]!
    var selectedChildKey: String?
    var selectedChild: MediaContainer<Metadata>?

    enum Section: Int {
        case title
        case buttons
        case seasons
        case episodes
        case roles
    }

    let baseSections: [Section] = [.title, .buttons]
    var displayedSections: [Section]!

    override func viewDidLoad() {
        super.viewDidLoad()
        displayedSections = baseSections
        tableView.register(cellView: MediaTitleTableViewCell.self)
        tableView.register(cellView: ButtonsTableViewCell.self)
        tableView.register(cellView: SeasonsTableViewCell.self)
        tableView.register(cellView: RolesTableViewCell.self)
        tableView.register(cellView: EpisodesTableViewCell.self)

        if let imagePath = metadata.art,
            let request = ApiFetcher.instance.urlRequestFor(server: server, imagePath: imagePath) {
            Nuke.loadImage(with: request, into: mainArtImageView)
        }

        if metadata.type == .show,
            let key = metadata.key {
            ApiFetcher.instance.getMetadataForChildren(server: server, key: key) { [unowned self] response, _ in
                if let children = response?.mediaContainer.content {
                    childrenMetadata = children
                    displayedSections.append(.seasons)
                    displayedSections.sort { $0.rawValue < $1.rawValue }
                    tableView.reloadData()
                }
            }
        }
        if let key = metadata.ratingKey {
            ApiFetcher.instance.getMetadataDetails(server: server, key: key) { [unowned self] response, _ in
                if let details = response?.mediaContainer.content.first {
                    metadataDetails = details
                    if details.roles != nil {
                        displayedSections.append(.roles)
                    }
                    displayedSections.sort { $0.rawValue < $1.rawValue }
                    tableView.reloadData()
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: mainArtImageView.frame.height - 200, left: 0, bottom: 32, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = appearance
    }

    func playerButtonPressed() {
        let playerController = AVPlayerViewController()
        if let part = metadata.medias?.first?.parts.first,
           let url = ApiFetcher.instance.playerUrlFor(server: server, part: part) {
            let player = AVPlayer(url: url)
            playerController.entersFullScreenWhenPlaybackBegins = true
            playerController.exitsFullScreenWhenPlaybackEnds = true
            playerController.player = player
            present(playerController, animated: true) {
                player.play()
            }
        }
    }

    func playMetadata(_ metadata: Metadata) {
        // check if local subtitles are working
        // https://stackoverflow.com/questions/39589710/how-to-add-external-vtt-subtitle-file-to-avplayerviewcontroller-in-tvos
        // https://github.com/mhergon/AVPlayerViewController-Subtitles
        let playerController = AVPlayerViewController()
        if let part = metadata.medias?.first?.parts.first,
           let url = ApiFetcher.instance.playerUrlFor(server: server, part: part) {
            let player = AVPlayer(url: url)
            playerController.entersFullScreenWhenPlaybackBegins = true
            playerController.exitsFullScreenWhenPlaybackEnds = true
            playerController.player = player
            present(playerController, animated: true) {
                player.play()
            }
        }
    }

    func didSelectSeason(_ metadata: Metadata) {
        let episodePath = IndexPath(row: Section.episodes.rawValue, section: 0)
        guard let key = metadata.key else {
            return
        }

        if displayedSections.contains(.episodes) {
            if selectedChildKey == key {
                selectedChildKey = nil
                selectedChild = nil
                displayedSections.remove(at: Section.episodes.rawValue)
                displayedSections.sort { $0.rawValue < $1.rawValue }
                tableView.deleteRows(at: [episodePath], with: .fade)
            } else {
                selectedChildKey = key
                ApiFetcher.instance.getMetadataForChildren(server: server, key: key) { [self] response, _ in
                    selectedChild = response?.mediaContainer
                    tableView.reloadRows(at: [episodePath], with: .fade)
                }
            }
        } else {
            selectedChildKey = key
            ApiFetcher.instance.getMetadataForChildren(server: server, key: key) { [self] response, _ in
                selectedChild = response?.mediaContainer
                displayedSections.append(.episodes)
                displayedSections.sort { $0.rawValue < $1.rawValue }
                tableView.insertRows(at: [episodePath], with: .fade)
                tableView.scrollToRow(at: episodePath, at: .none, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension MovieDetailsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch displayedSections[indexPath.row] {
        case .title:
            let cell = tableView.dequeueReusableCell(type: MediaTitleTableViewCell.self, for: indexPath)
            cell.configureGradient(bounds: tableView.bounds)
            cell.titleLabel.text = metadata.title
            return cell
        case .buttons:
            let cell = tableView.dequeueReusableCell(type: ButtonsTableViewCell.self, for: indexPath)
            cell.delegate = self
            cell.configureWith(metadata: metadata)
            return cell
        case .seasons:
            let cell = tableView.dequeueReusableCell(type: SeasonsTableViewCell.self, for: indexPath)
            cell.delegate = self
            cell.configureWith(server: server, metadatas: childrenMetadata)
            return cell
        case .roles:
            let cell = tableView.dequeueReusableCell(type: RolesTableViewCell.self, for: indexPath)
            if let roles = metadataDetails.roles {
                cell.configureWith(roles: roles)
            }
            return cell
        case .episodes:
            let cell = tableView.dequeueReusableCell(type: EpisodesTableViewCell.self, for: indexPath)
            cell.delegate = self
            if let episodes = selectedChild?.content {
                cell.configureWith(server: server, episodes: episodes)
            }
            return cell
        }
    }

}

// MARK: - UITableViewDelegate
extension MovieDetailsViewController: UITableViewDelegate {

}
