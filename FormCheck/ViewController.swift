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
        // Step 1b: push the camera shell screen
        let vc = CameraViewController()
        navigationController?.pushViewController(vc, animated: true)
        // If navigationController is nil, ensure SceneDelegate sets a UINavigationController as root.
    }
}
