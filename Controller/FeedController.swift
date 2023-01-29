//
//  FeedController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit
import SDWebImage

class FeedController: UIViewController {
    
//    MARK: Properties
    
    var user: User? {
        didSet {
            configureLeftBarButton()
        }
    } 

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
//    helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
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
