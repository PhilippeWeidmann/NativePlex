//
//  ViewController.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 09.06.21.
//

import UIKit
import NotificationToast

class MoviesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var metadatas = [Metadata]()
    private var directory: Directory?
    private var server: Server?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(cellView: MovieCollectionViewCell.self)
    }

    func setServerAndDirectory(server: Server, directory: Directory) {
        self.server = server
        self.directory = directory
        refreshDataSource()
    }

    func refreshDataSource() {
        if let directory = directory,
            let server = server {
            title = directory.title
            ApiFetcher.instance.getMetadataFor(server: server, section: directory.key) { [unowned self] response, error in
                if let response = response {
                    metadatas = response.mediaContainer.content
                    collectionView.reloadData()
                } else if let error = error {
                    switch error {
                    case .networkError(let error):
                        print(error)
                    case .decodingError(let error):
                        print(error)
                    default:
                        break
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let movieDetailsViewController = segue.destination as? MovieDetailsViewController,
            let serverAndMetadata = sender as? (Server, Metadata) {
            movieDetailsViewController.server = serverAndMetadata.0
            movieDetailsViewController.metadata = serverAndMetadata.1
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metadatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCell = collectionView.dequeueReusableCell(type: MovieCollectionViewCell.self, for: indexPath)
        let metadata = metadatas[indexPath.row]
        if let server = server {
            movieCell.configureWith(server: server, metadata: metadata)
        }
        return movieCell
    }
}

// MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let metadata = metadatas[indexPath.row]
        performSegue(withIdentifier: "movieDetailsSegue", sender: (server, metadata))
    }
}
