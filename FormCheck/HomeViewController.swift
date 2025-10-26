//
//  HomeViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Home screen with exercise selection
final class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Analyze your\nworkout"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("All exercises ▼", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let barbellSquatsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let barbellIconView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        imageView.image = UIImage(systemName: "figure.strengthtraining.traditional", withConfiguration: config)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let barbellTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Barbell Back Squats"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let barbellHeartButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bodyweightSquatsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bodyweightIconView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        imageView.image = UIImage(systemName: "figure.squat", withConfiguration: config)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let bodyweightTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Free Bodyweight Squats"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyweightHeartButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(dropdownButton)
        view.addSubview(favoriteButton)
        view.addSubview(searchButton)
        view.addSubview(barbellSquatsButton)
        view.addSubview(bodyweightSquatsButton)
        
        // Setup barbell button content
        barbellSquatsButton.addSubview(barbellIconView)
        barbellSquatsButton.addSubview(barbellTitleLabel)
        barbellSquatsButton.addSubview(barbellHeartButton)
        
        // Setup bodyweight button content
        bodyweightSquatsButton.addSubview(bodyweightIconView)
        bodyweightSquatsButton.addSubview(bodyweightTitleLabel)
        bodyweightSquatsButton.addSubview(bodyweightHeartButton)
        
        // Add button actions
        barbellSquatsButton.addTarget(self, action: #selector(barbellSquatsButtonTapped), for: .touchUpInside)
        bodyweightSquatsButton.addTarget(self, action: #selector(bodyweightSquatsButtonTapped), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // Dropdown button
            dropdownButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dropdownButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            dropdownButton.widthAnchor.constraint(equalToConstant: 150),
            dropdownButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Favorite button
            favoriteButton.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: dropdownButton.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Search button
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            searchButton.centerYAnchor.constraint(equalTo: dropdownButton.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 32),
            searchButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Barbell squats button
            barbellSquatsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            barbellSquatsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            barbellSquatsButton.topAnchor.constraint(equalTo: dropdownButton.bottomAnchor, constant: 32),
            barbellSquatsButton.heightAnchor.constraint(equalToConstant: 80),
            
            // Barbell icon
            barbellIconView.leadingAnchor.constraint(equalTo: barbellSquatsButton.leadingAnchor, constant: 20),
            barbellIconView.centerYAnchor.constraint(equalTo: barbellSquatsButton.centerYAnchor),
            barbellIconView.widthAnchor.constraint(equalToConstant: 32),
            barbellIconView.heightAnchor.constraint(equalToConstant: 32),
            
            // Barbell title
            barbellTitleLabel.leadingAnchor.constraint(equalTo: barbellIconView.trailingAnchor, constant: 16),
            barbellTitleLabel.centerYAnchor.constraint(equalTo: barbellSquatsButton.centerYAnchor),
            
            // Barbell heart
            barbellHeartButton.trailingAnchor.constraint(equalTo: barbellSquatsButton.trailingAnchor, constant: -20),
            barbellHeartButton.centerYAnchor.constraint(equalTo: barbellSquatsButton.centerYAnchor),
            barbellHeartButton.widthAnchor.constraint(equalToConstant: 32),
            barbellHeartButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Bodyweight squats button
            bodyweightSquatsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bodyweightSquatsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bodyweightSquatsButton.topAnchor.constraint(equalTo: barbellSquatsButton.bottomAnchor, constant: 16),
            bodyweightSquatsButton.heightAnchor.constraint(equalToConstant: 80),
            
            // Bodyweight icon
            bodyweightIconView.leadingAnchor.constraint(equalTo: bodyweightSquatsButton.leadingAnchor, constant: 20),
            bodyweightIconView.centerYAnchor.constraint(equalTo: bodyweightSquatsButton.centerYAnchor),
            bodyweightIconView.widthAnchor.constraint(equalToConstant: 32),
            bodyweightIconView.heightAnchor.constraint(equalToConstant: 32),
            
            // Bodyweight title
            bodyweightTitleLabel.leadingAnchor.constraint(equalTo: bodyweightIconView.trailingAnchor, constant: 16),
            bodyweightTitleLabel.centerYAnchor.constraint(equalTo: bodyweightSquatsButton.centerYAnchor),
            
            // Bodyweight heart
            bodyweightHeartButton.trailingAnchor.constraint(equalTo: bodyweightSquatsButton.trailingAnchor, constant: -20),
            bodyweightHeartButton.centerYAnchor.constraint(equalTo: bodyweightSquatsButton.centerYAnchor),
            bodyweightHeartButton.widthAnchor.constraint(equalToConstant: 32),
            bodyweightHeartButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func barbellSquatsButtonTapped() {
        let tutorialVC = ExerciseTutorialViewController()
        tutorialVC.exerciseName = "Barbell Back Squats"
        navigationController?.pushViewController(tutorialVC, animated: true)
    }
    
    @objc private func bodyweightSquatsButtonTapped() {
        let tutorialVC = ExerciseTutorialViewController()
        tutorialVC.exerciseName = "Free Bodyweight Squats"
        navigationController?.pushViewController(tutorialVC, animated: true)
    }
}
