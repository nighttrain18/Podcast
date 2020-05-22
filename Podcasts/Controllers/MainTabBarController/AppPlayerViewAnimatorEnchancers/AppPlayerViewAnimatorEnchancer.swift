//
//  AppPlayerViewAnimatorEnchancer.swift
//  Podcasts
//
//  Created by Олег Черных on 16/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

protocol AppPlayerViewAnimatorEnhancer: AppPlayerViewAnimator {
    var animator: AppPlayerViewAnimator { get set }
    func invoke(forAppPlayerView view: AppPlayerView)
}