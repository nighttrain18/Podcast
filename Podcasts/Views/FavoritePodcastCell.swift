//
//  FavoritesPodcastCell.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import Combine

final class FavoritePodcastCell: UICollectionViewCell {
    private let imageView = AsyncImageView()
    private let nameLabel = UILabel()
    private let artistNameLabel = UILabel()
    private let loadingImageIndicator = UIActivityIndicatorView()
    var viewModel: FavoritePodcastCellViewModel! {
        didSet {
            if self.viewModel != nil {
                artistNameLabel.text = self.viewModel.artistName
                nameLabel.text = self.viewModel.podcastName
                self.imageView.imageUrl = self.viewModel.podcastImageUrl
            }
        }
    }
    
    private var updateImageView: (() -> Void)!
    
    private func stylizeUI() {
        nameLabel.text = "Podcast name"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        artistNameLabel.text = "Artist name"
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    private func setupView() {
        imageView.backgroundColor = .systemGroupedBackground
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        //imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        loadingImageIndicator.hidesWhenStopped = true
        addSubview(loadingImageIndicator)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        viewModel = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stylizeUI()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadingImageIndicator.center = .init(x: bounds.width / 2, y: bounds.width / 2)
        imageView.frame.size = .init(width: bounds.width, height: bounds.width)
    }
}
