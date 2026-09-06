import UIKit
import CoreData

final class HomeViewController: UIViewController {
    private let missionLabel = UILabel()
    private let countLabel = UILabel()
    private let exploreButton = UIButton(type: .system)
    private let newSightingButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BioViva"
        configureView()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            NotificationCenter.default.addObserver(self, selector: #selector(refreshLocalSightingCount), name: AppDelegate.persistentStoreStateDidChange, object: appDelegate)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLocalSightingCount()
    }

    private func configureView() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = "BioViva"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        missionLabel.text = "Conheça a biodiversidade e fortaleça decisões ambientais mais conscientes."
        missionLabel.font = .preferredFont(forTextStyle: .body)
        missionLabel.numberOfLines = 0
        missionLabel.textColor = .secondaryLabel

        countLabel.font = .preferredFont(forTextStyle: .headline)
        countLabel.numberOfLines = 0
        countLabel.textAlignment = .center

        configure(button: exploreButton, title: "Explorar observações", image: "binoculars")
        configure(button: newSightingButton, title: "Registrar avistamento", image: "camera")
        exploreButton.addTarget(self, action: #selector(showObservations), for: .touchUpInside)
        newSightingButton.addTarget(self, action: #selector(showNewSighting), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, missionLabel, countLabel, exploreButton, newSightingButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            exploreButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            newSightingButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
    }

    private func configure(button: UIButton, title: String, image: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.image = UIImage(systemName: image)
        configuration.imagePadding = 8
        configuration.cornerStyle = .medium
        button.configuration = configuration
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    }

    private func updateLocalSightingCount() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            countLabel.text = "Avistamentos locais indisponíveis"
            return
        }
        let container = appDelegate.persistentContainer
        guard appDelegate.isPersistentStoreAvailable else {
            countLabel.text = "Avistamentos locais indisponíveis"
            return
        }
        let context = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalSighting")
        do {
            let count = try context.count(for: request)
            countLabel.text = "\(count) avistamento\(count == 1 ? "" : "s") local\(count == 1 ? "" : "is") registrado\(count == 1 ? "" : "s")"
        } catch {
            countLabel.text = "Não foi possível carregar os avistamentos locais"
        }
    }

    @objc private func refreshLocalSightingCount() {
        guard isViewLoaded, view.window != nil else { return }
        updateLocalSightingCount()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func showObservations() {
        performSegue(withIdentifier: "showObservations", sender: self)
    }

    @objc private func showNewSighting() {
        performSegue(withIdentifier: "showNewSighting", sender: self)
    }
}
