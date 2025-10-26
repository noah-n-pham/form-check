import UIKit

final class CameraViewController: UIViewController {
    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Camera will appear here"
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Camera"

        // Placeholder UI
        view.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        // The back button is shown automatically by UINavigationController when pushed.
        navigationItem.backButtonTitle = "Back"
    }
}
