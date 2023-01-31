//
//  UserCell.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 31. 1. 2023..
//

import UIKit

class UserCell: UITableViewCell {
    
    static let reuseIdentifier = "UserCell"
    
//    MARK: Properties
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .twitterBlue
        
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "username"
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "full name"
        return label
    }()
    
//    MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, nameLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: Lifecycle
    
    func configure() {
        guard let user = user else { return }
        
        guard let profilePicUrl = URL(string: user.profileImageUrl) else { return }
        profileImageView.sd_setImage(with: profilePicUrl)
        
        usernameLabel.text = user.username
        nameLabel.text = user.name
    }
    
}
