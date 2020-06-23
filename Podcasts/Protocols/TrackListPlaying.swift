//
//  PlayingTrackListManaging.swift
//  Podcasts
//
//  Created by Олег Черных on 09/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

struct Track {
    var episode: Episode
    var podcast: Podcast
    var url: URL
}

enum TrackListPlayerEvent {
    case initial([Track], Int)
    case playingTrackUpdated([Track], Int)
    case trackListUpdated([Track], Int)
}

protocol TrackListPlaying: class {
    func setTrackList(_ trackList: [Track], withPlayingTrackIndex trackIndex: Int)
    func playNextTrack()
    func playPreviousTrack()
    func subscribe(
        _ subscriber: @escaping (TrackListPlayerEvent) -> Void
    ) -> Subscription
}
