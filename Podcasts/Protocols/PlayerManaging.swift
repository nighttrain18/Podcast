//
//  Playermanaging.swift
//  Podcasts
//
//  Created by user166334 on 5/22/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit

enum PlayerManagingEvent: AppEvent {
    case playerStateUpdated(state: PlayerState)
}

protocol PlayerManaging: class {
    func fastForward15()
    func rewind15()
    func moveToPlaybackTime(_ playbackTime: CMTime)
    func playPause()
    func nextEpisode()
    func previousEpisode()
    func hasPreviousEpisode() -> Bool
    func hasNextEpisode() -> Bool
}