//
//  LoginController.swift
//  TwitterClone
//
//  Created by Amar Fazlic on 26. 1. 2023..
//

import UIKit

class LoginController: UIViewController {
    
//    properties
    
    private var areFieldsValid = false
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "TwitterLogo")
        return imageView
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
    
    private let emailTextField: UITextField = Utilities().textField(withPlaceholder: "Email")
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton(firstPart: "Don't have an account? ", secondPart: "Sign up")
        button.addTarget(self, action: #selector(goToSignUp), for: .touchUpInside)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    
//    lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @objc func goToSignUp() {
        let vc = RegisterController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleLogin() {
        validateFields()
        if !areFieldsValid {
            return
        }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.presentUIAlertController(withMessage: error.localizedDescription)
                return
            }
            
            UserDefaults.standard.set(result?.user.uid, forKey: "uid")
            UserDefaults.standard.set(email, forKey: "email")
            
            
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow
            }) else { return }
            
            guard let tab = window.rootViewController as? MainTabController else { return }
            
            tab.authUserAndConfigureUI()
            
            self.dismiss(animated: true)
        }
    }
    
    private func validateFields() {
        
        //        MARK: Email checks
        guard let emailText = emailTextField.text else {
            presentUIAlertController(withMessage: "You need to enter an email address!")
            return
        }
        if emailText.isEmpty {
            presentUIAlertController(withMessage: "You need to enter an email address!")
            return
        }
        if !emailText.isValidEmail() {
            presentUIAlertController(withMessage: "You need to enter a valid email address!")
            return
        }
        
        
        //        MARK: Password checks
        guard let passwordText = passwordTextField.text else {
            presentUIAlertController(withMessage: "You need to enter a password!")
            return
        }
        if passwordText.isEmpty {
            presentUIAlertController(withMessage: "You need to enter a password!")
            return
        }
        if passwordText.count < 6 {
            presentUIAlertController(withMessage: "Your password needs to be longer than 5 characters!")
            return
        }
        
        
        areFieldsValid = true
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
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        logoImageView.setDimensions(width: 150, height: 150)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 40, paddingBottom: 16, paddingRight: 16)
    }

}
