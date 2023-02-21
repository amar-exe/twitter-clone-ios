//
//  SuccessfullyRegisteredController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 21. 2. 2023..
//

import UIKit
import SnapKit

protocol SuccessfullyRegisteredControllerDelegate: AnyObject {
    func didTapOk()
}

class SuccessfullyRegisteredController: UIViewController {
    
//    MARK: Properties
    
    weak var delegate: SuccessfullyRegisteredControllerDelegate?
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.seal")
        return iv
    }()
    
    private let text: UILabel = {
        let label = UILabel()
        label.text = "Successfully signed up"
        label.textColor = .twitterBlue
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        configureUI()
        
            }
    
    @objc private func didTapButton() {
        
        delegate?.didTapOk()

    }
    
    func configureUI() {
        view.addSubview(image)
        image.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(128)
        }
        
        view.addSubview(text)
        text.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(text.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(32)
        }
    }

}
