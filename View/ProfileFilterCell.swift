//
//  ProfileFilterCell.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 31. 1. 2023..
//

import UIKit

class ProfileFilterCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ProfileFilterCell"
    
    //    MARK: Properties
    
    var option: ProfileFilterOptions! {
        didSet {
            titleLabel.text = option.description
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Test"
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 14)
            titleLabel.textColor = isSelected ? UIColor.twitterBlue : UIColor.lightGray
        }
    }
    
//    MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(titleLabel)
        titleLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
