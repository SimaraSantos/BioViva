import UIKit

final class ObservationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let stateLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let mapButton = UIButton(type: .system)
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Observações"
        configureView()
        loadObservationsIfNeeded()
    }

    private func configureView() {
        view.subviews.forEach { $0.removeFromSuperview() }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ObservationCell.self, forCellReuseIdentifier: ObservationCell.reuseIdentifier)
        tableView.rowHeight = 84
        view.addSubview(tableView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        stateLabel.font = .preferredFont(forTextStyle: .body)
        stateLabel.textAlignment = .center
        stateLabel.numberOfLines = 0
        stateLabel.translatesAutoresizingMaskIntoConstraints = false

        retryButton.setTitle("Tentar novamente", for: .normal)
        retryButton.addTarget(self, action: #selector(retryLoading), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        var mapConfiguration = UIButton.Configuration.tinted()
        mapConfiguration.title = "Abrir mapa"
        mapConfiguration.image = UIImage(systemName: "map")
        mapConfiguration.imagePadding = 8
        mapButton.configuration = mapConfiguration
        mapButton.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        mapButton.translatesAutoresizingMaskIntoConstraints = false

        let stateStack = UIStackView(arrangedSubviews: [stateLabel, retryButton])
        stateStack.axis = .vertical
        stateStack.alignment = .center
        stateStack.spacing = 12
        stateStack.translatesAutoresizingMaskIntoConstraints = false
        stateStack.isHidden = true
        stateStack.accessibilityIdentifier = "observationStateStack"
        view.addSubview(stateStack)
        view.addSubview(mapButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: mapButton.topAnchor, constant: -8),
            mapButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mapButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mapButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            mapButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stateStack.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private var stateStack: UIStackView? {
        view.subviews.compactMap { $0 as? UIStackView }.first { $0.accessibilityIdentifier == "observationStateStack" }
    }

    private func loadObservationsIfNeeded(force: Bool = false) {
        guard !isLoading else { return }
        guard force || ObservationStore.shared.observations.isEmpty else {
            tableView.reloadData()
            return
        }
        isLoading = true
        stateStack?.isHidden = true
        activityIndicator.startAnimating()
        INaturalistService.loadObservations { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let observations):
                ObservationStore.shared.replace(with: observations)
                self.tableView.reloadData()
                if observations.isEmpty {
                    self.showState(message: "Nenhuma observação encontrada no momento.", showsRetry: false)
                }
            case .failure:
                self.showState(message: "Não foi possível carregar as observações.", showsRetry: true)
            }
        }
    }

    private func showState(message: String, showsRetry: Bool) {
        stateLabel.text = message
        retryButton.isHidden = !showsRetry
        stateStack?.isHidden = false
    }

    @objc private func retryLoading() {
        loadObservationsIfNeeded(force: true)
    }

    @objc private func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ObservationStore.shared.observations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ObservationCell.reuseIdentifier, for: indexPath) as? ObservationCell else {
            return UITableViewCell()
        }
        cell.configure(with: ObservationStore.shared.observations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showObservationDetail", sender: ObservationStore.shared.observations[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showObservationDetail", let detail = segue.destination as? ObservationDetailViewController, let observation = sender as? INaturalistObservation {
            detail.observation = observation
        }
    }
}

private final class ObservationCell: UITableViewCell {
    static let reuseIdentifier = "ObservationCell"
    private let thumbnailView = UIImageView()
    private let nameLabel = UILabel()
    private let detailsLabel = UILabel()
    private var imageTask: URLSessionDataTask?
    private var thumbnailURL: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        thumbnailView.image = UIImage(systemName: "leaf")
        thumbnailView.tintColor = .systemGreen
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = 8
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        detailsLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.numberOfLines = 2
        let labels = UIStackView(arrangedSubviews: [nameLabel, detailsLabel])
        labels.axis = .vertical
        labels.spacing = 4
        labels.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbnailView)
        contentView.addSubview(labels)
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailView.heightAnchor.constraint(equalToConstant: 60),
            labels.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 12),
            labels.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            labels.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        thumbnailURL = nil
        thumbnailView.image = UIImage(systemName: "leaf")
    }

    func configure(with observation: INaturalistObservation) {
        imageTask?.cancel()
        imageTask = nil
        thumbnailURL = nil
        thumbnailView.image = UIImage(systemName: "leaf")
        nameLabel.text = observation.displayName
        let category = observation.taxon?.iconicTaxonName ?? "Categoria não informada"
        let date = observation.observedOn ?? "Data não informada"
        detailsLabel.text = "\(category) • \(date)"
        guard let url = observation.taxon?.defaultPhoto?.mediumURL else { return }
        thumbnailURL = url
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard let self, self.thumbnailURL == url else { return }
                self.thumbnailView.image = image
            }
        }
        imageTask?.resume()
    }
}
