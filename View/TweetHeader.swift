//
//  TweetHeader.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 1. 2. 2023..
//

import UIKit

class TweetHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "TweetHeader"
    
//    MARK: Properties
    
//    MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemTeal
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
