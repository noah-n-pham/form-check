import UIKit

final class ViewController: UIViewController {
    private let startButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "FormGuard"

        startButton.setTitle("Start Squat Analysis", for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        startButton.addTarget(self, action: #selector(tapStart), for: .touchUpInside)

        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 52),
            startButton.widthAnchor.constraint(equalToConstant: 260)
        ])
    }

    @objc private func tapStart() {
        // For Step 1a this can be a placeholder.
        // In Step 1b/Step 2 we'll push CameraViewController here.
        let alert = UIAlertController(
            title: "Next Step Ready",
            message: "This is where we'll open the camera screen in Step 1b.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
