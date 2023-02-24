//
//  ConversationCell.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 24. 2. 2023..
//

import UIKit

class ConversationCell: UITableViewCell {

    public static let reuseIdentifier = "ConversationCell"
    
//    MARK: Properties
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        return iv
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [userImageView, userNameLabel, userMessageLabel].forEach(contentView.addSubview)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 20)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height - 20) / 20)
    }
    
    public func configure(with model: String) {
        
    }
}
