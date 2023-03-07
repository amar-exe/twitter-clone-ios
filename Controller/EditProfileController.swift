//
//  EditProfileController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 6. 2. 2023..
//

import UIKit
import CropViewController

protocol EditProfileControllerDelegate: AnyObject {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
    func handleLogout()
}

class EditProfileController: UITableViewController {
    
//    MARK: Properties
    
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private let footerView = EditProfileFooter()
    
    weak var editProfileControllerDelegate: EditProfileControllerDelegate?
    
    private var userInfoChanged = false
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    
    private var selectedImage: UIImage? {
        didSet {
            headerView.profileImageView.image = selectedImage
        }
    }
    
//    MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
    }
    
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: Selectors
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc func handleDone() {
        view.endEditing(true)
        guard imageChanged || userInfoChanged else { return }
        updateUserData()
    }
    
//    MARK: API
    
    func updateUserData() {
        if imageChanged && !userInfoChanged {
            updateProfileImage()
        }
        
        if userInfoChanged && !imageChanged {
            UserService.shared.saveUserData(user: user) { err, ref in
                self.editProfileControllerDelegate?.controller(self, wantsToUpdate: self.user)
            }
        }
        
        if userInfoChanged && imageChanged {
            UserService.shared.saveUserData(user: user) { err, ref in
                self.updateProfileImage()
            }
        }
    }
    
    func updateProfileImage() {
        guard let image = selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { profileImageUrl in
            self.user.profileImageUrl = profileImageUrl
            self.editProfileControllerDelegate?.controller(self, wantsToUpdate: self.user)
        }
    }
    
//    MARK: Helpers
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .twitterBlue
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        footerView.editProfileFooterDelegate = self
        
        tableView.tableFooterView = footerView
        headerView.editProfileHeaderDelegate = self
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: EditProfileCell.reuseIdentifier)
    }
    
}

extension EditProfileController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
            
        case .fullname:
            guard let fullname = cell.infoTextField.text else { return }
            user.name = fullname
        case .username:
            guard let username = cell.infoTextField.text else { return }
            user.username = username
        case .bio:
            guard let bio = cell.bioTextView.text else { return }
            user.bio = bio
        }
    }
}

extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileCell.reuseIdentifier, for: indexPath) as! EditProfileCell
        
        cell.editProfileCellDelegate = self
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell }
        cell.viewModel = EditProfileViewModel(user: user, options: option)
        
        return cell
    }
}

extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return option == .bio ? 100 : 48
        
    }
}

extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true)
        showCrop(image: profileImage)
        
    }
}

extension EditProfileController: CropViewControllerDelegate {
    
    func showCrop(image: UIImage) {
        let vc = CropViewController(croppingStyle: .circular, image: image)
        vc.aspectRatioPreset = .presetSquare
        vc.aspectRatioLockEnabled = false
        vc.toolbarPosition = .bottom
        vc.doneButtonTitle = "Continue"
        vc.doneButtonColor = .twitterBlue
        vc.cancelButtonTitle = "Cancel"
        vc.cancelButtonColor = .systemRed
        vc.delegate = self
        
        present(vc, animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        self.selectedImage = image
    }
}

extension EditProfileController: EditProfileFooterDelegate {
    func handleLogout() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            
            self.dismiss(animated: true) {
                self.editProfileControllerDelegate?.handleLogout()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}
