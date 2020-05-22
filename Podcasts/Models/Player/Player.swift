//
//  Player.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit

enum PlayerEvent {
    case playingEpisodeChanged(playedEpisode: PlayedEpisode)
    case playerStateUpdated(state: PlayerState)
}

struct PlayedEpisode {
    var index: Int
    var episode: Episode
}

struct PlayerState {
    var timePast: CMTime
    var duration: CMTime
    var volumeLevel: Int
    var isPlaying: Bool
}

class Player {
    // MARK: - private properties
    fileprivate lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if let item = self.player.currentItem {
                self.playerState = PlayerState(
                    timePast: item.currentTime(),
                    duration: item.duration,
                    volumeLevel: 10,
                    isPlaying: self.player.timeControlStatus == .playing
                )
            }
        }
        return player
    }()
    private var subscribers: [UUID:(PlayerEvent) -> Void] = [:]
    // MARK: - observable properties
    private var episodePlayingList: [Episode]!
    private var playedEpisodeIndex: Int!
    private var podcast: Podcast!
    
    private(set) var playerState: PlayerState! {
        didSet {
            notifyAll(withEvent: .playerStateUpdated(state: self.playerState))
        }
    }
    
    // MARK: - Singleton
    private init() {}
    static let shared = Player()
    
    // MARK: - player api
    // public for Player extension to get access. How to fix it???
    func fastForward15() {
        shiftByTime(15)
    }
    
    func rewind15() {
        shiftByTime(-15)
    }
    
    func playPause() {
        if player.timeControlStatus == .playing {
            player.pause()
            playerState.isPlaying = false
        } else {
            player.play()
            playerState.isPlaying = true
        }
    }
    
    func moveToPlaybackTime(_ playbackTime: CMTime) {
        seekToTime(playbackTime)
    }
    
    func seekToTime(_ seekTime: CMTime) {
        player.currentItem?.seek(to: seekTime, completionHandler: { [weak self] (res) in
            if res {
            }
        })
    }
    
    func pause() {
        playerState.isPlaying = false
    }
    
    func nextEpisode() {
        let nextPlayedEpisodeIndex = playedEpisodeIndex + 1
        if nextPlayedEpisodeIndex == episodePlayingList.count {
            return
        }
        
        play(episodeAt: nextPlayedEpisodeIndex)
    }
    
    func previousEpisode() {
        let nextPlayedEpisodeIndex = playedEpisodeIndex - 1
        if nextPlayedEpisodeIndex < 0 {
            return
        }
        
        play(episodeAt: nextPlayedEpisodeIndex)
    }
    
    func hasNextEpisode() -> Bool {
        return playedEpisodeIndex + 1 != episodePlayingList.count
    }
    
    func hasPreviousEpisode() -> Bool {
        return playedEpisodeIndex - 1 >= 0
    }
    
    // MARK: - helpers
    private func shiftByTime(_ time: Int64) {
        let playbackTime = player.currentTime()
        let shiftTime = CMTime(seconds: Double(time), preferredTimescale: 1)
        let seekTime = CMTimeAdd(playbackTime, shiftTime)
        seekToTime(seekTime)
    }
    
    private func notifyAll(withEvent event: PlayerEvent) {
        subscribers.values.forEach { $0(event) }
    }
    
    private func play(episodeAt index: Int) {
        let nextPlayedEpisode = episodePlayingList[index]
        let playerItem = AVPlayerItem(url: nextPlayedEpisode.streamUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        notifyAll(withEvent: .playingEpisodeChanged(playedEpisode: .init(index: index, episode: nextPlayedEpisode)))
    }
}

extension Player: EpisodeListPlayable {
    func play(episodeByIndex episodeIndex: Int, inEpisodeList episodes: [Episode], of podcast: Podcast) {
        if self.podcast == podcast {
            if playedEpisodeIndex == episodeIndex {
                return
            }
            
            self.playedEpisodeIndex = episodeIndex
            return
        }
        
        self.podcast = podcast
        playedEpisodeIndex = episodeIndex
        episodePlayingList = episodes
    }
    
    func subscribe(_ subscriber: @escaping (PlayerEvent) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription(canceller: { [unowned self] in self.subscribers.removeValue(forKey: key) })
    }
}
