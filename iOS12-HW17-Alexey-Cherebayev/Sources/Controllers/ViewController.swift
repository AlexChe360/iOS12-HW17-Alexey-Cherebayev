//
//  ViewController.swift
//  iOS12-HW17-Alexey-Cherebayev
//
//  Created by  Alexey on 21.03.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    // MARK: - UI
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "Security password"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.systemGray5
        textField.layer.cornerRadius = 5
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        return view
    }()
    
    private lazy var generatePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Generate", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(generateDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(stopDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var actionView: UIView = {
        let view = UIView()
        view.addSubviews([
            generatePasswordButton,
            stopButton
        ])
        return view
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.text = "Result"
        label.numberOfLines = 0
        label.textColor = UIColor.black
        return label
    }()
    
    // MARK: - Properties
    private var showedPassword: String = "" {
        didSet {
            resultLabel.text = showedPassword
        }
    }
    
    private var isBruteForcingStopped: Bool = false {
        didSet {
            if isBruteForcingStopped {
                resultLabel.text = "Ваш пароль не взломан"
                passwordTextField.isSecureTextEntry = true
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: - Setups
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupHierarchy() {
        view.addSubviews([
            passwordTextField,
            activityIndicatorView,
            actionView,
            resultLabel
        ])
    }
    
    private func setupLayout() {
        passwordTextField.snp.makeConstraints { make in
            make.left.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(45)
            make.right.equalTo(activityIndicatorView.snp.left).offset(-10)
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.right.equalTo(view.safeAreaInsets).offset(-10)
            make.centerY.equalTo(passwordTextField.snp.centerY)
        }
        
        actionView.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(15)
            make.left.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(50)
        }
        
        generatePasswordButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.47)
            make.centerY.equalTo(actionView.snp.centerY)
            make.height.equalTo(40)
        }
        
        stopButton.snp.makeConstraints { make in
            make.right.equalTo(actionView)
            make.centerY.equalTo(generatePasswordButton.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.47)
            make.height.equalTo(40)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(actionView.snp.bottom).offset(15)
            make.left.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
    }

    // MARK: - Actions
    
    @objc func generateDidTap() {
        let password = generateRandomPassword(length: 3)
        passwordTextField.text = password
        DispatchQueue.global(qos: .background).async {
            self.bruteForce(passwordToUnlock: password)
        }
    }
    
    @objc func stopDidTap() {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.resultLabel.textColor = .systemRed
            
        }
        self.isBruteForcingStopped = true
    }
    
    // MARK: - Functions
    
    private func generateRandomPassword(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password: String = ""

        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock && !isBruteForcingStopped { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            DispatchQueue.main.async {
                self.activityIndicatorView.isHidden = false
                self.activityIndicatorView.startAnimating()
                self.showedPassword = password
            }
        }
        
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.passwordTextField.isSecureTextEntry = false
            self.resultLabel.text = password
        }
    }
    
    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
                                   : Character("")
    }

    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string

        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        }
        else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }

        return str
    }

}

