//
//  SelfUserCell.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 6. 3. 2023..
//

import UIKit

class SelfUserCell: UITableViewCell {
    
    static let reuseIdentifier = "SelfUserCell"
    
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
        iv.setDimensions(width: 65, height: 65)
        iv.layer.cornerRadius = 65 / 2
        
        return iv
    }()
    
    func getProfileImage() -> UIImage {
        return profileImageView.image ?? UIImage()
    }
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    func getUsernameLabelText() -> String {
        return usernameLabel.text ?? ""
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    func getNameLabelText() -> String {
        return nameLabel.text ?? ""
    }
    
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
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        usernameLabel.text = user.username
        nameLabel.text = user.name
    }
    
}

