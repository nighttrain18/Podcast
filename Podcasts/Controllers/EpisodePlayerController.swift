//
//  EpisodePlayerController.swift
//  Podcasts
//
//  Created by Олег Черных on 07/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class EpisodePlayerController: UIViewController {
    weak var playerView: EpisodePlayerView! {
        didSet {
            self.playerView.delegate = self
        }
    }
    
    fileprivate lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            self?.updatePlayerViewWithEpisodePlayer()
        }
        return player
    }()
    
    override func loadView() {
        super.loadView()
        
        guard
            let playerView = Bundle.main.loadNibNamed(
                "EpisodePlayerView",
                owner: self,
                options: nil
            )?.first as? EpisodePlayerView else { fatalError("EpisodePlayerView doesn't exist") }
        
        view = UIView()
        self.playerView = playerView
        view.addSubview(playerView)
    }
    
    var episode: Episode! {
        didSet {
            let playerItem = AVPlayerItem(url: self.episode.streamUrl)
            player.replaceCurrentItem(with: playerItem)
            if playerView != nil {
                updatePlayerViewWithEpisodePlayer()
                updatePlayerViewWithEpisode()
                player.play()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if playerView.episode == nil {
            updatePlayerViewWithEpisodePlayer()
            updatePlayerViewWithEpisode()
            player.play()
        }
    }
    
    // NOT FIRED!!!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        playerView.frame = view.bounds
    }
    
    fileprivate func updatePlayerViewWithEpisode() {
        if episode != playerView.episode {
            playerView.episode = episode
        }
    }
    
    fileprivate func updatePlayerViewWithEpisodePlayer() {
        playerView.episodePlayer = EpisodePlayer(
            timePast: player.currentItem!.currentTime(),
            duration: player.currentItem!.duration,
            volumeLevel: 10,
            isPlaying: player.timeControlStatus == .playing
        )
    }
}

extension EpisodePlayerController: EpisodePlayerViewDelegate {
    func dissmis() {
        
    }
    
    func fastForward15() {
        shiftByTime(15)
    }
    
    func rewind15() {
        shiftByTime(-15)
    }
    
    func playPause() {
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
        updatePlayerViewWithEpisodePlayer()
    }
    
    func moveToPlaybackTime(_ playbackTime: CMTime) {
        seekToTime(playbackTime)
    }
    
    func shiftByTime(_ time: Int64) {
        let playbackTime = player.currentTime()
        let shiftTime = CMTime(seconds: Double(time), preferredTimescale: 1)
        let seekTime = CMTimeAdd(playbackTime, shiftTime)
        seekToTime(seekTime)
    }
    
    func seekToTime(_ seekTime: CMTime) {
        player.currentItem?.seek(to: seekTime, completionHandler: { [weak self] (res) in
            if res {
                self?.updatePlayerViewWithEpisodePlayer()
            }
        })
    }
}