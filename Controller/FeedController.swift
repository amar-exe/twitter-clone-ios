//
//  FeedController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit
import SDWebImage

class FeedController: UICollectionViewController {
    
//    MARK: Properties
    
    var user: User? {
        didSet {
            configureLeftBarButton()
        }
    }
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
//    MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self

        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
//    MARK: API
    
    func fetchTweets() {
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets
        }
    }
    
//    helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        self.collectionView!.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        
        guard let profilePicUrl = URL(string: user.profileImageUrl) else { return }
        
        profileImageView.sd_setImage(with: profilePicUrl)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}


extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

extension FeedController: TweetCellDelegate {
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
