//
//  EpisodesControllers.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import FeedKit
import PromiseKit

class FavoriteButtonItem: UIBarButtonItem {
    var isFavorite: Bool! {
        didSet {
            if self.isFavorite {
                self.image = UIImage(named: "heart")!
            } else {
                self.title = "Favorite"
                self.image = nil
            }
        }
    }
}

class EpisodesController: UITableViewController {
    private let cellId = "episodeCell"
    fileprivate var favoriteButton: FavoriteButtonItem {
        return navigationItem.rightBarButtonItem as! FavoriteButtonItem
    }
    // MARK: - dependencies
    var episodesModel: EpisodesModel! {
        didSet {
            self.episodesModel.initialize()
            self.episodesModel.subscriber = { [weak self] event in
                self?.updateViewWithModel(withEvent: event)
            }
        }
    }
    // MARK: - view life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        let favoriteButton = FavoriteButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(onFavoriteButtonTapped)
        )
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    // MARK: - interaction handlers
    @objc
    fileprivate func onFavoriteButtonTapped() {
        if !favoriteButton.isFavorite {
            episodesModel.addPodcastToFavorites()
        }
    }
    // MARK: - helpers
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func updateViewWithModel(withEvent event: EpisodesModel.Event) {
        switch event {
        case .initialized:
            tableView.reloadData()
            favoriteButton.isFavorite = episodesModel.isPodcastFavorite
        case .podcastStatusUpdated:
            favoriteButton.isFavorite = episodesModel.isPodcastFavorite
        case .episodeDownloadingProgressUpdated:
            let indexPathsToReload = tableView.visibleCells
                .map { $0 as! EpisodeCell }
                .filter { episodesModel.downloadingEpisodes[$0.episode] != nil }
                .map { tableView.indexPath(for: $0)! }
            indexPathsToReload
                .map { tableView.cellForRow(at: $0) as! EpisodeCell }
                .forEach { $0.episodeRecordStatus = .downloading }
            break
        case .episodeDownloaded:
            // todo
            break
        default:
            break
        }
    }
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodesModel.episodes[indexPath.row]
        cell.episode = episode
        // todo
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodesModel.episodes.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        episodesModel.pickEpisode(episodeIndex: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.startAnimating()
        activityIndicatorView.color = .darkGray
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodesModel.episodes.count == 0 ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Download") { [weak self] (_, _, completionHandler) in
            self?.episodesModel.downloadEpisode(episodeIndex: indexPath.row)
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
}
