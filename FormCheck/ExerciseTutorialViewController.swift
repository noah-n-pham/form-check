//
//  ExerciseTutorialViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import ImageIO
import AVFoundation
import AVKit

/// Tutorial screen showing exercise information and proper form
final class ExerciseTutorialViewController: UIViewController {
    
    // MARK: - Properties
    
    var exercise: Exercise?
    private var exerciseName: String {
        return exercise?.name ?? "Exercise"
    }
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
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
    
    private let videoPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let videoPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tutorial of ideal form"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let figureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let primaryMusclesLabel: UILabel = {
        let label = UILabel()
        label.text = "Primary Muscles:"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let primaryMusclesListLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let secondaryMusclesLabel: UILabel = {
        let label = UILabel()
        label.text = "Secondary Muscles:"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let secondaryMusclesListLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let understandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I understand", for: .normal)
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
        updateContent()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        title = exerciseName
        
        // Configure navigation bar
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(videoPlaceholderView)
        videoPlaceholderView.addSubview(videoPlaceholderLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(figureImageView)
        contentView.addSubview(primaryMusclesLabel)
        contentView.addSubview(primaryMusclesListLabel)
        contentView.addSubview(secondaryMusclesLabel)
        contentView.addSubview(secondaryMusclesListLabel)
        view.addSubview(understandButton)
        
        // Add button action
        understandButton.addTarget(self, action: #selector(understandButtonTapped), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: understandButton.topAnchor, constant: -16),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Video placeholder
            videoPlaceholderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            videoPlaceholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            videoPlaceholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            videoPlaceholderView.heightAnchor.constraint(equalToConstant: 200),
            
            // Video placeholder label
            videoPlaceholderLabel.centerXAnchor.constraint(equalTo: videoPlaceholderView.centerXAnchor),
            videoPlaceholderLabel.centerYAnchor.constraint(equalTo: videoPlaceholderView.centerYAnchor),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: videoPlaceholderView.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Figure image
            figureImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            figureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            figureImageView.widthAnchor.constraint(equalToConstant: 100),
            figureImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Primary muscles label
            primaryMusclesLabel.topAnchor.constraint(equalTo: figureImageView.bottomAnchor, constant: 24),
            primaryMusclesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            primaryMusclesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Primary muscles list (right below primary label)
            primaryMusclesListLabel.topAnchor.constraint(equalTo: primaryMusclesLabel.bottomAnchor, constant: 8),
            primaryMusclesListLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            primaryMusclesListLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Secondary muscles label (placed after primary list with extra margin)
            secondaryMusclesLabel.topAnchor.constraint(equalTo: primaryMusclesListLabel.bottomAnchor, constant: 16),
            secondaryMusclesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            secondaryMusclesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Secondary muscles list (right below secondary label)
            secondaryMusclesListLabel.topAnchor.constraint(equalTo: secondaryMusclesLabel.bottomAnchor, constant: 8),
            secondaryMusclesListLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            secondaryMusclesListLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            secondaryMusclesListLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Understand button
            understandButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            understandButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            understandButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            understandButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Update Content
    
    private func updateContent() {
        guard let exercise = exercise else { return }
        
        // Update navigation title
        title = exerciseName
        
        // Update description
        descriptionLabel.text = exercise.description
        
        // Update primary muscles
        primaryMusclesListLabel.text = exercise.primaryMuscles
        
        // Update secondary muscles
        secondaryMusclesListLabel.text = exercise.secondaryMuscles
        
        // Update tutorial image (supports both static images and animated GIFs)
        if let bundled = UIImage(named: exercise.tutorialImageName) {
            // Try to load as animated GIF if possible
            if let asset = NSDataAsset(name: exercise.tutorialImageName),
               let source = CGImageSourceCreateWithData(asset.data as CFData, nil),
               CGImageSourceGetCount(source) > 1 {
                // This is an animated GIF - load all frames
                loadAnimatedGIF(from: source)
            } else {
                // Static image
                figureImageView.image = bundled
            }
        } else {
            // Fallback to system symbol
            let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
            figureImageView.image = UIImage(systemName: "figure.stand", withConfiguration: config)
            figureImageView.tintColor = .white
        }
        
        // Update animation/video placeholder - Load MP4 video
        loadVideo(named: exercise.animationAssetName)
    }
    
    // MARK: - Helper Methods
    
    private func loadVideo(named assetName: String) {
        // Clean up previous player if exists
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        
        // Try to find the video file in the asset bundle
        if let asset = NSDataAsset(name: assetName) {
            // Save video data to temporary file
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(assetName).mp4")
            do {
                try asset.data.write(to: tempURL)
                setupVideoPlayer(with: tempURL)
                videoPlaceholderLabel.isHidden = true
            } catch {
                print("Error writing video file: \(error)")
                videoPlaceholderLabel.isHidden = false
            }
        } else {
            // Fallback - try to load from bundle directly
            if let videoURL = Bundle.main.url(forResource: assetName, withExtension: "mp4") {
                setupVideoPlayer(with: videoURL)
                videoPlaceholderLabel.isHidden = true
            } else {
                print("Video asset not found: \(assetName)")
                videoPlaceholderLabel.isHidden = false
            }
        }
    }
    
    private func setupVideoPlayer(with url: URL) {
        // Create player
        player = AVPlayer(url: url)
        
        // Create player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoPlaceholderView.bounds
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            videoPlaceholderView.layer.addSublayer(playerLayer)
        }
        
        // Setup looping
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        // Start playing
        player?.play()
    }
    
    @objc private func playerDidFinishPlaying(notification: Notification) {
        // Loop the video
        player?.seek(to: .zero)
        player?.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update player layer frame when view layout changes
        playerLayer?.frame = videoPlaceholderView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause video when leaving the screen
        player?.pause()
    }
    
    deinit {
        // Clean up observer
        NotificationCenter.default.removeObserver(self)
        player?.pause()
    }
    
    private func loadAnimatedGIF(from source: CGImageSource) {
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: TimeInterval = 0
        
        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                // Get frame duration
                let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
                let gifProperties = frameProperties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                let frameDuration = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? Double ?? 0.1
                
                totalDuration += frameDuration
                images.append(UIImage(cgImage: cgImage))
            }
        }
        
        if !images.isEmpty {
            figureImageView.animationImages = images
            figureImageView.animationDuration = totalDuration
            figureImageView.animationRepeatCount = 0 // Loop forever
            figureImageView.startAnimating()
        }
    }
    
    // MARK: - Actions
    
    @objc private func understandButtonTapped() {
        let cameraVC = CameraViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}

