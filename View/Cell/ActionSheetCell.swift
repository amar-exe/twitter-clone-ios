//
//  ActionSheetCell.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 2. 2. 2023..
//

import UIKit

class ActionSheetCell: UITableViewCell {
    
    static let reuseIdentifier = "ActionSheetCell"
    
//    MARK: Properties
    
    var options: ActionSheetOptions? {
        didSet {
            configure()
        }
    }
    
    private let optionImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "twitter_logo_blue")
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Option"
        return label
    }()
    
    func getTitleLabelText() -> String {
        return titleLabel.text ?? ""
    }
    
//    MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(optionImageView)
        optionImageView.centerY(inView: self)
        optionImageView.anchor(left: leftAnchor, paddingLeft: 8)
        optionImageView.setDimensions(width: 36, height: 36)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: self)
        titleLabel.anchor(left: optionImageView.rightAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: Helpers
    
    func configure() {
        titleLabel.text = options?.description
    }
    
}
