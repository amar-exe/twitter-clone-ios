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
