//
//  NotificationsController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit

class NotificationsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    

//    helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Notifications"
    }

}
