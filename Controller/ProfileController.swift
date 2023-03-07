//
//  ProfileController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 30. 1. 2023..
//

import UIKit
import Firebase

class ProfileController: UICollectionViewController {
    
//    MARK: Properties
    
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var tweets = [Tweet]()
    private var likedTweets = [Tweet]()
    private var replies = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets:
            return tweets
        case .replies:
            return replies
        case .likes:
            return likedTweets
        }
    }
    
//    MARK: Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        fetchTweets()
        fetchLikedTweets()
        fetchReplies()
        checkIfUserIsFollowed()
        fetchUserStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    
//    MARK: API
    
    func fetchTweets() {
        TweetService.shared.fetchTweets(forUser: user) { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedTweets()
            self.collectionView.reloadData()
                }
        
//        TweetService.shared.fetchTweets(forUser: user, limit: UInt(3)) { tweets in
//            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
////            self.tweets = self.tweets.uniqued()
//            self.checkIfUserLikedTweets()
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
    }
    
    func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { tweets in
            self.replies = tweets
        }
    }
    
    func fetchLikedTweets() {
        TweetService.shared.fetchLikes(forUser: user) { tweets in
            self.likedTweets = tweets
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) {stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    
//    MARK: Helpers
    
    func configureCollectionView() {
        
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        
        self.collectionView!.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        self.collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.reuseIdentifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight

    }

}

//MARK: UICollectionViewDelegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.reuseIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = currentDataSource[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 300
        
        if user.bio != nil {
            height += user.bio?.height(withConstrainedWidth: view.frame.width - 40, font: .systemFont(ofSize: 16)) ?? 50
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var height = viewModel.size(forWidth: view.frame.width).height + 72
        
        if currentDataSource[indexPath.row].isReply {
            height += 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
}

extension ProfileController: ProfileHeaderDelegate {
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func handleProfileHeaderFollow(_ header: ProfileHeader) {
        
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.editProfileControllerDelegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { ref, err in
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { ref, err in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
            }
        }
    }
    
    func dismissProfilePage() {
        navigationController?.popViewController(animated: true)
    }
}

extension ProfileController: EditProfileControllerDelegate {
    
    func handleLogout() {
        do {
            let vc = UINavigationController(rootViewController: LoginController())
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            try Auth.auth().signOut()
        } catch let error {
            print("failed to signout with error \(error.localizedDescription)")
        }
    }
    
       
    
    func controller(_ controller: EditProfileController, wantsToUpdate user: User) {
        controller.dismiss(animated: true)
        self.user = user
        self.collectionView.reloadData()
    }
}

extension ProfileController {
    func checkIfUserLikedTweets() {
        self.currentDataSource.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                if let index = self.currentDataSource.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.setLike(forIndex: index)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func setLike(forIndex index: Int) {
        switch selectedFilter {
        case .tweets:
            self.tweets[index].didLike = true
        case .replies:
            self.replies[index].didLike = true
        case .likes:
            self.likedTweets[index].didLike = true
        }
    }
}

extension ProfileController: TweetCellDelegate {
    func handleShareTapped(_ cell: TweetCell) {
        guard let tweetText = cell.tweet?.caption else { return }
        
        let shareSheetVC = UIActivityViewController(
            activityItems: [
                tweetText
            ], applicationActivities: nil)
        
        present(shareSheetVC, animated: true)
    }
    
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true )
        }
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let vc = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweet(forTweet: tweet) { err, ref in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: tweet.user,
                                                          type: .like,
                                                          tweetID: tweet.tweetID)
        }
    }
    
    
}
