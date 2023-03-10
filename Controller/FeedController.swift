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
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.setDimensions(width: 32, height: 32)
        iv.layer.cornerRadius = 32 / 2
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        let configuration = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.darkGray)
        iv.image = UIImage(systemName: "person.circle.fill", withConfiguration: configuration)
        return iv
    }()
    
    
    let itemsPerPage: UInt = 3
    var pageNum = 0
    
    private var backgroundView: UIView!
    
    var user: User? {
        didSet {
            setImageForLeftBarButtonItem()
        }
    }
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
            backgroundView.isHidden = !tweets.isEmpty
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
//    MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self

        configureUI()
        
        configureLeftBarButton()
        fetchTweets()
        
        configureTableBackgroundView()
        
        collectionView.backgroundView = backgroundView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        
        fetchTweets()
    }
    
//    MARK: API
    
//    func fetchTweets() {
//        collectionView.refreshControl?.beginRefreshing()
//        TweetService.shared.fetchTweets { tweets in
//            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
//            self.checkIfUserLikedTweets()
//            self.collectionView.refreshControl?.endRefreshing()
//        }
//        collectionView.refreshControl?.endRefreshing()
//    }
    
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        TweetService.shared.fetchTweets(limit: itemsPerPage, completion: { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedTweets()
            self.collectionView.refreshControl?.endRefreshing()
        })
        collectionView.refreshControl?.endRefreshing()
    }
    
    func checkIfUserLikedTweets() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    
//    MARK: Selectors
    
    @objc func handleRefresh() {
        tweets = []
        fetchTweets()
    }
    
    @objc func handleProfileImageTap() {
        guard var selfUser = user else { return }
        
        let controller = ProfileController(user: selfUser)
        controller.profileControllerDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
//    MARK: Helpers
    
    func configureTableBackgroundView() {
        backgroundView = UIView(frame: collectionView.bounds)
        backgroundView.backgroundColor = .white // set the background color
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 2
        messageLabel.text = "No tweets in your feed yet!\nTry following someone" // set the message to display
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
        ])
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        self.collectionView!.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func setImageForLeftBarButtonItem() {
        guard let user = user else { return }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    func configureLeftBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}

extension FeedController: ProfileControllerDelegate {
    func updateUser(withUser user: User) {
        self.user = user
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - contentOffset
        
        if deltaOffset <= 0 {
            pageNum += 1
//            fetchTweets(page: currentPage) { fetchedTweets in
//                self.tweets.append(contentsOf: fetchedTweets)
//                self.collectionView.reloadData()
//            }
            
            guard var lastTweet = tweets.last else { return }
        
            
            TweetService.shared.fetchTweets(startingAfter: lastTweet, limit: itemsPerPage, completion: { tweets in
                guard tweets.first?.tweetID != self.tweets.last?.tweetID else { return }
                self.tweets.append(contentsOf: tweets.sorted(by: { $0.timestamp > $1.timestamp }))
                self.tweets = self.tweets.uniqued()
                self.checkIfUserLikedTweets()
                self.collectionView.refreshControl?.endRefreshing()
            })
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 72)
    }
}

extension FeedController: TweetCellDelegate {
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
