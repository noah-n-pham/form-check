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
    case favorites = "Favorites"
    case withEquipment = "With equipment"
    case noEquipment = "No equipment"
}

/// Home screen with exercise selection
final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currentFilter: ExerciseFilter = .all
    private var filteredExercises: [Exercise] = ExerciseDataSource.allExercises
    private var searchQuery: String = ""
    private var favoriteExerciseNames: Set<String> = []
    private let favoritesKey = "FormCheck_FavoriteExercises"
    
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
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search exercises..."
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .black
        searchBar.tintColor = .white
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private var searchBarHeightConstraint: NSLayoutConstraint?
    
    private let exerciseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFavorites()
        setupUI()
        setupActions()
        updateExerciseDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButtonAppearance()
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
        view.addSubview(searchBar)
        view.addSubview(scrollView)
        scrollView.addSubview(exerciseStackView)
        
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
            
            // Search bar (initially hidden)
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            searchBar.topAnchor.constraint(equalTo: dropdownButton.bottomAnchor, constant: 8),
            
            // Scroll view
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Exercise stack view
            exerciseStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            exerciseStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            exerciseStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            exerciseStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            exerciseStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
        ])
        
        // Create and store height constraint for animation
        searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 0)
        searchBarHeightConstraint?.isActive = true
        
        searchBar.delegate = self
        searchBar.alpha = 0
    }
    
    private func setupActions() {
        // Dropdown action
        let dropdownAction = UIAction { [weak self] _ in
            self?.showFilterMenu()
        }
        dropdownButton.addAction(dropdownAction, for: .touchUpInside)
        
        // Favorite button action
        let favoriteAction = UIAction { [weak self] _ in
            self?.toggleFavoritesFilter()
        }
        favoriteButton.addAction(favoriteAction, for: .touchUpInside)
        
        // Search button action
        let searchAction = UIAction { [weak self] _ in
            self?.toggleSearch()
        }
        searchButton.addAction(searchAction, for: .touchUpInside)
    }
    
    // MARK: - Favorites Management
    
    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteExerciseNames = Set(savedFavorites)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteExerciseNames), forKey: favoritesKey)
    }
    
    private func toggleFavorite(for exercise: Exercise) {
        if favoriteExerciseNames.contains(exercise.name) {
            favoriteExerciseNames.remove(exercise.name)
        } else {
            favoriteExerciseNames.insert(exercise.name)
        }
        saveFavorites()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Update display
        updateExerciseDisplay()
        updateFavoriteButtonAppearance()
    }
    
    private func isFavorite(_ exercise: Exercise) -> Bool {
        return favoriteExerciseNames.contains(exercise.name)
    }
    
    private func toggleFavoritesFilter() {
        if currentFilter == .favorites {
            selectFilter(.all)
        } else {
            selectFilter(.favorites)
        }
    }
    
    private func updateFavoriteButtonAppearance() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        if currentFilter == .favorites {
            favoriteButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .normal)
            favoriteButton.tintColor = .systemPink
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
            favoriteButton.tintColor = .white
        }
    }
    
    // MARK: - Search Management
    
    private func toggleSearch() {
        let isSearchVisible = searchBar.alpha > 0
        
        if isSearchVisible {
            // Hide search
            searchBar.resignFirstResponder()
            searchBarHeightConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBar.alpha = 0
                self.view.layoutIfNeeded()
            }) { _ in
                self.searchBar.text = ""
                self.searchQuery = ""
                self.updateFilteredExercises()
                self.updateExerciseDisplay()
            }
        } else {
            // Show search
            searchBarHeightConstraint?.constant = 50
            
            UIView.animate(withDuration: 0.3) {
                self.searchBar.alpha = 1
                self.view.layoutIfNeeded()
            }
            searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - Filter Management
    
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
        updateFavoriteButtonAppearance()
    }
    
    private func updateFilteredExercises() {
        // First apply category filter
        var exercises: [Exercise]
        switch currentFilter {
        case .all:
            exercises = ExerciseDataSource.allExercises
        case .favorites:
            exercises = ExerciseDataSource.allExercises.filter { favoriteExerciseNames.contains($0.name) }
        case .withEquipment:
            exercises = ExerciseDataSource.allExercises.filter { $0.requiresEquipment }
        case .noEquipment:
            exercises = ExerciseDataSource.allExercises.filter { !$0.requiresEquipment }
        }
        
        // Then apply search filter
        if !searchQuery.isEmpty {
            exercises = exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchQuery) ||
                exercise.description.localizedCaseInsensitiveContains(searchQuery) ||
                exercise.primaryMuscles.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        filteredExercises = exercises
    }
    
    private func updateExerciseDisplay() {
        // Clear existing buttons
        exerciseStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if filteredExercises.isEmpty {
            // Show empty state
            let emptyLabel = UILabel()
            if currentFilter == .favorites {
                emptyLabel.text = "No favorite exercises yet.\nTap the ♡ on any exercise to add it!"
            } else if !searchQuery.isEmpty {
                emptyLabel.text = "No exercises found matching '\(searchQuery)'"
            } else {
                emptyLabel.text = "No exercises available"
            }
            emptyLabel.font = .systemFont(ofSize: 16, weight: .regular)
            emptyLabel.textColor = .gray
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            exerciseStackView.addArrangedSubview(emptyLabel)
        } else {
            // Create buttons for filtered exercises
            for exercise in filteredExercises {
                let button = createExerciseButton(for: exercise)
                exerciseStackView.addArrangedSubview(button)
            }
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
        let isFav = isFavorite(exercise)
        let heartImage = isFav ? "heart.fill" : "heart"
        heartButton.setImage(UIImage(systemName: heartImage, withConfiguration: heartConfig), for: .normal)
        heartButton.tintColor = isFav ? .systemPink : .white
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
        
        // Add action to main button
        button.addAction(UIAction { [weak self] _ in
            self?.openExerciseTutorial(exercise)
        }, for: .touchUpInside)
        
        // Add action to heart button (prevent propagation)
        heartButton.addAction(UIAction { [weak self] _ in
            self?.toggleFavorite(for: exercise)
        }, for: .touchUpInside)
        
        return button
    }
    
    private func openExerciseTutorial(_ exercise: Exercise) {
        let tutorialVC = ExerciseTutorialViewController()
        tutorialVC.exercise = exercise
        navigationController?.pushViewController(tutorialVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        updateFilteredExercises()
        updateExerciseDisplay()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchQuery = ""
        searchBar.resignFirstResponder()
        updateFilteredExercises()
        updateExerciseDisplay()
    }
}
