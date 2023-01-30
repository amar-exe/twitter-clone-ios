//
//  TweetCell.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 30. 1. 2023..
//

import UIKit

class TweetCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TweetCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
