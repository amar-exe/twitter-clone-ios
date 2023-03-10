//
//  TweetController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 1. 2. 2023..
//

import UIKit

class TweetController: UICollectionViewController {
    
//    MARK: Properties
    
    private let tweet: Tweet
    private var actionSheetLauncher: ActionSheetLauncher!
    private var replies = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
//    MARK: Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchReplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
//    MARK: API
    
    func fetchReplies() {
        TweetService.shared.fetchReplies(forTweet: tweet) { replies in
            self.replies = replies
        }
    }
    
//    MARK: Helpers
    
    fileprivate func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.actionSheetLauncherDelegate = self
        actionSheetLauncher.show()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        
        self.collectionView!.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        self.collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TweetHeader.reuseIdentifier)
    }
}

//MARK: UICollectionViewDelegate
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TweetHeader.reuseIdentifier, for: indexPath) as! TweetHeader
        header.tweet = tweet
        header.tweetHeaderDelegate = self
        return header
    }
}

extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = replies[indexPath.row]
        return cell
    }
}

extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: tweet)
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: captionHeight + 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

extension TweetController: TweetHeaderDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true )
        }
    }
    
    
    func showActionSheet() {
        
        if tweet.user.isCurrentUser {
            showActionSheet(forUser: tweet.user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: tweet.user.uid) { isFollowed in
                var user = self.tweet.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
        
    }
}

extension TweetController: ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
            
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { err, ref in
                print("followed user")
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { err, ref in
                print("unfollowed")
            }
        case .report:
            print("report tweet")
        case .delete:
            print("delete tweeet")
        }
    }
}
