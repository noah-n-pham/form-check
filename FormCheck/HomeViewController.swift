//
//  HomeViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Filter type for exercises
enum ExerciseFilter: String, CaseIterable {
    case all = "All exercises"
    case withEquipment = "With equipment"
    case noEquipment = "No equipment"
}

/// Home screen with exercise selection
final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currentFilter: ExerciseFilter = .all
    private var filteredExercises: [Exercise] = ExerciseDataSource.allExercises
    
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
    
    private let exerciseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDropdownAction()
        updateExerciseDisplay()
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
        view.addSubview(exerciseStackView)
        
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
            
            // Exercise stack view
            exerciseStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            exerciseStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            exerciseStackView.topAnchor.constraint(equalTo: dropdownButton.bottomAnchor, constant: 32),
        ])
    }
    
    private func setupDropdownAction() {
        let action = UIAction { [weak self] _ in
            self?.showFilterMenu()
        }
        dropdownButton.addAction(action, for: .touchUpInside)
    }
    
    private func showFilterMenu() {
        let alertController = UIAlertController(title: "Filter Exercises", message: nil, preferredStyle: .actionSheet)
        
        for filter in ExerciseFilter.allCases {
            let action = UIAlertAction(title: filter.rawValue, style: .default) { [weak self] _ in
                self?.selectFilter(filter)
            }
            // Mark current selection
            if filter == currentFilter {
                action.setValue(true, forKey: "checked")
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = dropdownButton
            popover.sourceRect = dropdownButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func selectFilter(_ filter: ExerciseFilter) {
        currentFilter = filter
        dropdownButton.setTitle("\(filter.rawValue) ▼", for: .normal)
        updateFilteredExercises()
        updateExerciseDisplay()
    }
    
    private func updateFilteredExercises() {
        switch currentFilter {
        case .all:
            filteredExercises = ExerciseDataSource.allExercises
        case .withEquipment:
            filteredExercises = ExerciseDataSource.allExercises.filter { $0.requiresEquipment }
        case .noEquipment:
            filteredExercises = ExerciseDataSource.allExercises.filter { !$0.requiresEquipment }
        }
    }
    
    private func updateExerciseDisplay() {
        // Clear existing buttons
        exerciseStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create buttons for filtered exercises
        for exercise in filteredExercises {
            let button = createExerciseButton(for: exercise)
            exerciseStackView.addArrangedSubview(button)
        }
    }
    
    private func createExerciseButton(for exercise: Exercise) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = exercise.buttonColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Icon view
        let iconView = UIImageView()
        // Check if there's a custom icon in assets
        if let customIconName = exercise.customButtonIconName, let customIcon = UIImage(named: customIconName) {
            // Render custom icon as template to make it white
            iconView.image = customIcon.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = .white
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
            iconView.image = UIImage(systemName: exercise.buttonIconName, withConfiguration: config)
            iconView.tintColor = .white
        }
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = exercise.name
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Heart button
        let heartButton = UIButton(type: .system)
        let heartConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        heartButton.setImage(UIImage(systemName: "heart", withConfiguration: heartConfig), for: .normal)
        heartButton.tintColor = .white
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        button.addSubview(iconView)
        button.addSubview(titleLabel)
        button.addSubview(heartButton)
        
        // Layout
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            heartButton.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 32),
            heartButton.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        // Add action
        button.addAction(UIAction { [weak self] _ in
            self?.openExerciseTutorial(exercise)
        }, for: .touchUpInside)
        
        return button
    }
    
    private func openExerciseTutorial(_ exercise: Exercise) {
        let tutorialVC = ExerciseTutorialViewController()
        tutorialVC.exercise = exercise
        navigationController?.pushViewController(tutorialVC, animated: true)
    }
}
