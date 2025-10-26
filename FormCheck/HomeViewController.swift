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
    
    // Main title matching figma
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Analyze your\nworkout"
        label.font = .systemFont(ofSize: 34, weight: .bold) // adjusted to match figma better
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // All exercises dropdown button
    private let exercisesDropdown: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("All exercises ", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        btn.contentHorizontalAlignment = .left
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        // Add chevron
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let chevronImage = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
        btn.setImage(chevronImage, for: .normal)
        btn.tintColor = .white
        btn.semanticContentAttribute = .forceRightToLeft
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        return btn
    }()
    
    // Heart icon button
    private let heartButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let img = UIImage(systemName: "heart", withConfiguration: config)
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // Search icon button
    private let searchButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // Exercise cards matching figma design
    private let barbellSquatsCard: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.systemOrange
        btn.layer.cornerRadius = 18 // more rounded like figma
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let bodyweightSquatsCard: UIButton = {
        let btn = UIButton(type: .system)
        // Purple/blue gradient-ish color from figma
        btn.backgroundColor = UIColor(red: 0.42, green: 0.45, blue: 0.85, alpha: 1.0)
        btn.layer.cornerRadius = 18 // more rounded like figma
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExerciseCards()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Dark background like figma
        view.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(exercisesDropdown)
        view.addSubview(heartButton)
        view.addSubview(searchButton)
        view.addSubview(barbellSquatsCard)
        view.addSubview(bodyweightSquatsCard)
        
        // Add button actions
        barbellSquatsCard.addTarget(self, action: #selector(barbellSquatsTapped), for: .touchUpInside)
        bodyweightSquatsCard.addTarget(self, action: #selector(bodyweightSquatsTapped), for: .touchUpInside)
        
        // Layout constraints matching figma
        NSLayoutConstraint.activate([
            // Title - top left
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            // Search button - top right
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            // Heart button - next to search
            heartButton.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor),
            
            // Exercises dropdown
            exercisesDropdown.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            exercisesDropdown.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            
            // Barbell squats card
            barbellSquatsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            barbellSquatsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            barbellSquatsCard.topAnchor.constraint(equalTo: exercisesDropdown.bottomAnchor, constant: 20),
            barbellSquatsCard.heightAnchor.constraint(equalToConstant: 68), // slightly smaller
            
            // Bodyweight squats card
            bodyweightSquatsCard.leadingAnchor.constraint(equalTo: barbellSquatsCard.leadingAnchor),
            bodyweightSquatsCard.trailingAnchor.constraint(equalTo: barbellSquatsCard.trailingAnchor),
            bodyweightSquatsCard.topAnchor.constraint(equalTo: barbellSquatsCard.bottomAnchor, constant: 12),
            bodyweightSquatsCard.heightAnchor.constraint(equalToConstant: 68)
        ])
    }
    
    private func setupExerciseCards() {
        // Setup barbell squats card content
        setupCardContent(
            card: barbellSquatsCard,
            iconName: "dumbbell.fill",
            title: "Barbell Back Squats",
            color: .systemOrange
        )
        
        // Setup bodyweight squats card content
        setupCardContent(
            card: bodyweightSquatsCard,
            iconName: "bolt.fill",
            title: "Free Bodyweight Squats",
            color: .systemPurple
        )
    }
    
    private func setupCardContent(card: UIButton, iconName: String, title: String, color: UIColor) {
        // Icon view on the left
        let iconView = UIImageView()
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconView.image = UIImage(systemName: iconName, withConfiguration: iconConfig)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold) // slightly smaller
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        // Heart icon on the right
        let heartIcon = UIImageView()
        let heartConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        heartIcon.image = UIImage(systemName: "heart", withConfiguration: heartConfig)
        heartIcon.tintColor = .white.withAlphaComponent(0.9) // slightly transparent
        heartIcon.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconView)
        card.addSubview(titleLbl)
        card.addSubview(heartIcon)
        
        NSLayoutConstraint.activate([
            // Icon on left
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),
            
            // Title next to icon
            titleLbl.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            titleLbl.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            // Heart on right
            heartIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            heartIcon.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func barbellSquatsTapped() {
        print("🏋️ Barbell squats selected")
        // Navigate to test harness / camera view
        let testVC = FeedbackTestViewController()
        navigationController?.pushViewController(testVC, animated: true)
    }
    
    @objc private func bodyweightSquatsTapped() {
        print("⚡ Bodyweight squats selected")
        // Navigate to test harness / camera view
        let testVC = FeedbackTestViewController()
        navigationController?.pushViewController(testVC, animated: true)
    }
}

