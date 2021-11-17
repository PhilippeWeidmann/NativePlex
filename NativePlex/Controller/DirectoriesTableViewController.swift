//
//  SourcesTableViewController.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 11.06.21.
//

import UIKit

class DirectoriesTableViewController: UITableViewController {
    var servers = [Server]()

    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        let appeareance = UINavigationBarAppearance()
        appeareance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appeareance
        navigationItem.scrollEdgeAppearance = appeareance
        navigationItem.searchController = searchController
        tableView.register(cellView: DirectoryTableViewCell.self)

        reloadData()
    }

    func reloadData() {
        guard SessionPreferences.shared.userLoggedIn else {
            return
        }

        ApiFetcher.instance.getServers { response, error in
            if let servers = response?.servers {
                self.servers = servers
                for server in servers {
                    ApiFetcher.instance.getDirectories(server: server) { [unowned self] response, error in
                        if let response = response {
                            server.directories = response.mediaContainer.content
                            tableView.reloadData()
                            if tableView.indexPathForSelectedRow == nil {
                                let firstIndex = IndexPath(row: 0, section: 0)
                                tableView.selectRow(at: firstIndex, animated: false, scrollPosition: .none)
                                selectServerAndDirectory(server: server, directory: server.directories[firstIndex.row])
                            }
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
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return servers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers[section].directories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(type: DirectoryTableViewCell.self, for: indexPath)
        let directory = servers[indexPath.section].directories[indexPath.row]
        cell.titleLabel.text = directory.title
        cell.iconImageView.image = directory.type.icon
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let server = servers[indexPath.section]
        let directory = server.directories[indexPath.row]
        selectServerAndDirectory(server: server, directory: directory)
    }

    func selectServerAndDirectory(server: Server, directory: Directory) {
        if let moviesNavigationViewController = (splitViewController?.viewController(for: .secondary) as? UINavigationController) {
            moviesNavigationViewController.popToRootViewController(animated: false)
            if let moviesViewController = moviesNavigationViewController.viewControllers.first as? MoviesViewController {
                moviesViewController.setServerAndDirectory(server: server, directory: directory)
            }
        }
    }
}
