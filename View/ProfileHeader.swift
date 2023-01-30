//
//  ProfileHeader.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 30. 1. 2023..
//

import UIKit

class ProfileHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "ProfileHeader"
    
//    MARK: Properties
    
//    MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
