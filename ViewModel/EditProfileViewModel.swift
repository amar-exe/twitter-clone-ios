//
//  EditProfileViewModel.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 6. 2. 2023..
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
            
        case .fullname:
            return "Name"
        case .username:
            return "Username"
        case .bio:
            return "Bio"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        
        case .fullname:
            return user.name
        case .username:
            return user.username
        case .bio:
            return user.bio
        }
    }
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    init(user: User, options: EditProfileOptions) {
        self.user = user
        self.option = options
    }
}
