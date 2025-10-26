//
//  ExerciseTutorialViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation
import AVKit
import ImageIO

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
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        setupVideoPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update player layer frame when container size changes
        if let playerLayer = playerLayer, playerLayer.frame != videoContainerView.bounds {
            playerLayer.frame = videoContainerView.bounds
            print("🔄 Player layer frame updated to: \(videoContainerView.bounds)")
        }
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
        
        contentView.addSubview(videoContainerView)
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
            
            // Video container
            videoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            videoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            videoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            videoContainerView.heightAnchor.constraint(equalToConstant: 200),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: 24),
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

            // Primary muscles list
            primaryMusclesListLabel.topAnchor.constraint(equalTo: primaryMusclesLabel.bottomAnchor, constant: 8),
            primaryMusclesListLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            primaryMusclesListLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Secondary muscles label
            secondaryMusclesLabel.topAnchor.constraint(equalTo: primaryMusclesListLabel.bottomAnchor, constant: 16),
            secondaryMusclesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            secondaryMusclesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Secondary muscles list
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
    
    // MARK: - Video Setup
    
    private func setupVideoPlayer() {
        // Use the video asset name from the exercise model
        guard let exercise = exercise else {
            print("❌ No exercise data available")
            return
        }
        
        let videoAssetName = exercise.animationAssetName
        
        // Load video from asset catalog
        guard let videoAsset = NSDataAsset(name: videoAssetName) else {
            print("❌ Could not load video asset: \(videoAssetName)")
            return
        }
        
        // Create temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let videoURL = tempDirectory.appendingPathComponent("\(videoAssetName).mp4")
        
        do {
            // Write video data to temp file
            try videoAsset.data.write(to: videoURL)
            
            // Create player item and player
            let playerItem = AVPlayerItem(url: videoURL)
            player = AVPlayer(playerItem: playerItem)
            
            // Create player layer
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.backgroundColor = UIColor.clear.cgColor
            
            if let playerLayer = playerLayer {
                videoContainerView.layer.addSublayer(playerLayer)
            }
            
            // Observe player item status to start playing when ready
            playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
            
            // Set frame after adding to layer hierarchy
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.playerLayer?.frame = self.videoContainerView.bounds
                print("📐 Player layer frame set to: \(self.videoContainerView.bounds)")
            }
            
            // Loop video
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
            
            print("✅ Video loaded successfully: \(videoAssetName)")
            
        } catch {
            print("❌ Error loading video: \(error.localizedDescription)")
        }
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
    }
    
    // MARK: - Helper Methods
    
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
        let demoVC = TutorialDemoViewController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    // MARK: - KVO Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .readyToPlay:
                    print("✅ Video ready to play - starting playback")
                    DispatchQueue.main.async { [weak self] in
                        self?.player?.play()
                        print("▶️ Video playing")
                    }
                case .failed:
                    print("❌ Video failed to load: \(playerItem.error?.localizedDescription ?? "unknown error")")
                case .unknown:
                    print("⏳ Video status unknown")
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        player?.pause()
        player = nil
    }
}
