//
//  SessionSummaryViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Session summary screen with performance insights and coaching advice
final class SessionSummaryViewController: UIViewController {
    
    // MARK: - Properties
    
    var sessionSummary: SessionSummary?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set Complete! 🎉"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let performanceRatingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Stats Card Container
    private let statsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Insights Card
    private let insightsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let insightsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "💡 Key Insight"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mostCommonIssueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemYellow
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Coaching Card
    private let coachingCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coachingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎯 Coaching Advice"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coachingAdviceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Trend Card
    private let trendCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let trendLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Session Summary"
        navigationItem.hidesBackButton = true
        
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(performanceRatingLabel)
        contentView.addSubview(statsCardView)
        statsCardView.addSubview(statsStackView)
        contentView.addSubview(insightsCardView)
        insightsCardView.addSubview(insightsTitleLabel)
        insightsCardView.addSubview(mostCommonIssueLabel)
        contentView.addSubview(coachingCardView)
        coachingCardView.addSubview(coachingTitleLabel)
        coachingCardView.addSubview(coachingAdviceLabel)
        contentView.addSubview(trendCardView)
        trendCardView.addSubview(trendLabel)
        view.addSubview(doneButton)
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        // Layout
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            performanceRatingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            performanceRatingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            performanceRatingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            statsCardView.topAnchor.constraint(equalTo: performanceRatingLabel.bottomAnchor, constant: 24),
            statsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            statsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            statsCardView.heightAnchor.constraint(equalToConstant: 100),
            
            statsStackView.topAnchor.constraint(equalTo: statsCardView.topAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: -16),
            
            insightsCardView.topAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: 16),
            insightsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            insightsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            insightsTitleLabel.topAnchor.constraint(equalTo: insightsCardView.topAnchor, constant: 16),
            insightsTitleLabel.leadingAnchor.constraint(equalTo: insightsCardView.leadingAnchor, constant: 16),
            insightsTitleLabel.trailingAnchor.constraint(equalTo: insightsCardView.trailingAnchor, constant: -16),
            
            mostCommonIssueLabel.topAnchor.constraint(equalTo: insightsTitleLabel.bottomAnchor, constant: 12),
            mostCommonIssueLabel.leadingAnchor.constraint(equalTo: insightsCardView.leadingAnchor, constant: 16),
            mostCommonIssueLabel.trailingAnchor.constraint(equalTo: insightsCardView.trailingAnchor, constant: -16),
            mostCommonIssueLabel.bottomAnchor.constraint(equalTo: insightsCardView.bottomAnchor, constant: -16),
            
            coachingCardView.topAnchor.constraint(equalTo: insightsCardView.bottomAnchor, constant: 16),
            coachingCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            coachingCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            coachingTitleLabel.topAnchor.constraint(equalTo: coachingCardView.topAnchor, constant: 16),
            coachingTitleLabel.leadingAnchor.constraint(equalTo: coachingCardView.leadingAnchor, constant: 16),
            coachingTitleLabel.trailingAnchor.constraint(equalTo: coachingCardView.trailingAnchor, constant: -16),
            
            coachingAdviceLabel.topAnchor.constraint(equalTo: coachingTitleLabel.bottomAnchor, constant: 12),
            coachingAdviceLabel.leadingAnchor.constraint(equalTo: coachingCardView.leadingAnchor, constant: 16),
            coachingAdviceLabel.trailingAnchor.constraint(equalTo: coachingCardView.trailingAnchor, constant: -16),
            coachingAdviceLabel.bottomAnchor.constraint(equalTo: coachingCardView.bottomAnchor, constant: -16),
            
            trendCardView.topAnchor.constraint(equalTo: coachingCardView.bottomAnchor, constant: 16),
            trendCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            trendCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            trendCardView.heightAnchor.constraint(equalToConstant: 70),
            trendCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            trendLabel.centerYAnchor.constraint(equalTo: trendCardView.centerYAnchor),
            trendLabel.leadingAnchor.constraint(equalTo: trendCardView.leadingAnchor, constant: 16),
            trendLabel.trailingAnchor.constraint(equalTo: trendCardView.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func populateData() {
        guard let summary = sessionSummary else { return }
        
        // Performance Rating
        let (rating, color, message) = getPerformanceRating(for: summary.averageScore)
        performanceRatingLabel.text = "\(rating)\n\(message)"
        performanceRatingLabel.textColor = color
        
        // Stats Cards
        createStatCard(title: "TOTAL REPS", value: "\(summary.totalReps)")
        createStatCard(title: "AVERAGE", value: "\(summary.averageScore)")
        createStatCard(title: "HIGHEST", value: "\(summary.highestScore)")
        createStatCard(title: "LOWEST", value: "\(summary.lowestScore)")
        
        // Most Common Issue
        if let issue = summary.mostCommonIssue, summary.issueCount > 0 {
            mostCommonIssueLabel.text = "Most common form issue: \"\(issue)\"\nAppeared in \(summary.issueCount) out of \(summary.totalReps) reps"
            
            // Coaching Advice
            coachingAdviceLabel.text = getCoachingAdvice(for: issue)
        } else {
            mostCommonIssueLabel.text = "No major form issues detected! Your technique is looking solid. 💪"
            coachingAdviceLabel.text = "Keep up the great work! Focus on maintaining this quality as you increase volume or weight."
        }
        
        // Performance Trend
        if summary.totalReps >= 4 {
            if summary.performanceTrend > 2 {
                trendLabel.text = "📈 Form Improved During Set\nYou got better as you went!"
                trendLabel.textColor = .systemGreen
            } else if summary.performanceTrend < -2 {
                trendLabel.text = "📉 Form Declined During Set\nWatch out for fatigue affecting technique"
                trendLabel.textColor = .systemOrange
            } else {
                trendLabel.text = "➡️ Consistent Performance\nYou maintained steady form throughout"
                trendLabel.textColor = .systemBlue
            }
        } else {
            trendLabel.text = "Complete 4+ reps to see performance trends"
            trendLabel.textColor = .gray
        }
        
        // Animate in
        animateAppearance()
    }
    
    private func createStatCard(title: String, value: String) {
        let container = UIView()
        container.backgroundColor = .clear
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4)
        ])
        
        statsStackView.addArrangedSubview(container)
    }
    
    private func getPerformanceRating(for score: Int) -> (String, UIColor, String) {
        switch score {
        case 90...100:
            return ("Excellent! 🌟", .systemGreen, "Outstanding form quality")
        case 80...89:
            return ("Great! 💪", .systemGreen, "Strong performance")
        case 70...79:
            return ("Good 👍", .systemBlue, "Solid technique")
        case 60...69:
            return ("Getting Better 📈", .systemYellow, "Keep improving")
        default:
            return ("Keep Practicing 🎯", .systemOrange, "Focus on form basics")
        }
    }
    
    private func getCoachingAdvice(for issue: String) -> String {
        let lowercased = issue.lowercased()
        
        if lowercased.contains("knee") && lowercased.contains("forward") {
            return "Focus on sitting back into your hips rather than pushing your knees forward. Keep your weight centered on your heels and think about 'sitting back into a chair' during the descent."
        } else if lowercased.contains("too deep") || lowercased.contains("going too deep") {
            return "Stop your descent when your thighs reach parallel to the ground. Control your depth by setting up a visual marker or working on body awareness. Excessive depth can compromise form."
        } else if lowercased.contains("not deep enough") || lowercased.contains("depth") {
            return "Aim to lower until your thighs are at least parallel to the ground. If mobility is limiting you, work on hip and ankle flexibility. Start with bodyweight box squats to build the pattern."
        } else if lowercased.contains("back") && (lowercased.contains("upright") || lowercased.contains("angle")) {
            return "Keep your chest up and core braced throughout the movement. Imagine a string pulling your chest toward the ceiling. Your eyes should look straight ahead or slightly up, not down."
        } else if lowercased.contains("hip") {
            return "Ensure your hips and shoulders rise at the same rate. If your hips shoot up first, you're losing tension. Drive through your heels and keep your torso angle consistent."
        } else if lowercased.contains("knee") && lowercased.contains("cave") {
            return "Actively push your knees outward throughout the movement. Think 'knees out' as you squat. This engages your glutes and prevents valgus collapse. Consider adding band work to strengthen this pattern."
        } else {
            return "Focus on the fundamentals: chest up, core tight, weight on heels, and controlled tempo. Film yourself from the side to identify specific areas for improvement."
        }
    }
    
    private func animateAppearance() {
        // Fade in and slide up animation
        let views = [statsCardView, insightsCardView, coachingCardView, trendCardView]
        
        for (index, view) in views.enumerated() {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 30)
            
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        // Navigate back to home
        navigationController?.popToRootViewController(animated: true)
    }
}

