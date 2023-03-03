//
//  RegisterController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase
import CropViewController

class RegisterController: UIViewController {
    
    //    properties
    
    private var profileImage: UIImage?
    private var areFieldsValid = false
    
    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton(firstPart: "Already have an account? ", secondPart: "Log in")
        button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let image = UIImage(named: "ic_mail_outline_white_2x-1")
        let view = Utilities().inputContainerView(withImage: image!, textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let image = UIImage(named: "ic_lock_outline_white_2x")
        let view = Utilities().inputContainerView(withImage: image!, textField: passwordTextField)
        return view
    }()
    
    private lazy var nameContainerView: UIView = {
        let image = UIImage(named: "ic_person_outline_white_2x")
        let view = Utilities().inputContainerView(withImage: image!, textField: nameTextField)
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let image = UIImage(named: "ic_person_outline_white_2x")
        let view = Utilities().inputContainerView(withImage: image!, textField: usernameTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email")
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let nameTextField: UITextField = Utilities().textField(withPlaceholder: "Full Name")
    
    private let usernameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Username")
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    //    lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.accessibilityIdentifier = "emailOnRegisterTextField"
        nameTextField.accessibilityIdentifier = "nameOnRegisterTextField"
        usernameTextField.accessibilityIdentifier = "usernameOnRegisterTextField"
        passwordTextField.accessibilityIdentifier = "passwordOnRegisterTextField"
        registerButton.accessibilityIdentifier = "registerButton"
        
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //    selectors
    
    @objc private func goToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func handleRegister() {
        validateFields()
        if !areFieldsValid {
            return
        }
        guard let profileImage = profileImage else { return }
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return }
        
        let credentials = AuthCredentials(email: email, password: password, name: name, username: username, profileImage: profileImage)
        
        AuthService.shared.registerUser(credentials: credentials) { error, ref in
            if error != nil {
                return
            }
            
            ConversationService.shared.insertUser(with: credentials) { bool in
                if bool {
                    print("inserted user")
                    return
                }
                print("didn't insert user")
            }
        }
        
        let alert = UIAlertController(title: nil, message: "You have been registered successfully", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.dismiss(animated: true)
            
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow
            }) else { return }
            
            guard let tab = window.rootViewController as? MainTabController else { return }
            
            tab.authUserAndConfigureUI()
            
            self.dismiss(animated: true)
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
        
        
    }
    
    @objc private func handleDismissal() {
        dismiss(animated: true)
    }
    
    private func validateFields() {
        
        //        MARK: Profile Image Checks
        guard let _ = profileImage else {
            presentUIAlertController(withMessage: "You need to add a profile picture!")
            return
        }
        
        //        MARK: Email checks
        guard let emailText = emailTextField.text else {
            presentUIAlertController(withMessage: "You need to add a email address!")
            return
        }
        if emailText.isEmpty {
            presentUIAlertController(withMessage: "You need to add a email address!")
            return
        }
        if !emailText.isValidEmail() {
            presentUIAlertController(withMessage: "You need to enter a valid email address!")
            return
        }
        
        
        //        MARK: Password checks
        guard let passwordText = passwordTextField.text else {
            presentUIAlertController(withMessage: "You need to add a password!")
            return
        }
        if passwordText.isEmpty {
            presentUIAlertController(withMessage: "You need to add a password!")
            return
        }
        if passwordText.count < 6 {
            presentUIAlertController(withMessage: "Your password needs to be longer than 5 characters!")
            return
        }
        
        //        MARK: Name checks
        guard let nameText = nameTextField.text else {
            presentUIAlertController(withMessage: "You need to add a name!")
            return
        }
        if nameText.isEmpty {
            presentUIAlertController(withMessage: "You need to add a name!")
            return
        }
        
        //        MARK: Username checks
        guard let usernameText = usernameTextField.text else {
            presentUIAlertController(withMessage: "You need to add a username!")
            return
        }
        if usernameText.isEmpty {
            presentUIAlertController(withMessage: "You need to add a username!")
            return
        }
        
        ConversationService.shared.userExists(with: emailText) { exists in
            guard !exists else {
                self.presentUIAlertController(withMessage: "User with this email address already exists!")
                return
            }
            self.areFieldsValid = true
        }
        
        return
    }
    
    private func presentUIAlertController(withMessage message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    //    helpers
    
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
        view.addSubview(addPhotoButton)
        addPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 64)
        addPhotoButton.setDimensions(width: 128, height: 128)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, nameContainerView, usernameContainerView, registerButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.anchor(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 40, paddingBottom: 16, paddingRight: 16)
    }
    
}

extension RegisterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true)
        
        showCrop(image: profileImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension RegisterController: CropViewControllerDelegate {
    
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
        
        self.profileImage = image
        addPhotoButton.layer.cornerRadius = 128 / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.imageView?.contentMode = .scaleAspectFill
        addPhotoButton.imageView?.clipsToBounds = true
        addPhotoButton.layer.borderColor = UIColor.white.cgColor
        addPhotoButton.layer.borderWidth = 3
        
        self.addPhotoButton.setImage(profileImage?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}
