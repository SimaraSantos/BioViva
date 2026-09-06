import UIKit

final class ObservationDetailViewController: UIViewController {
    var observation: INaturalistObservation?

    private let imageView = UIImageView()
    private let commonNameLabel = UILabel()
    private let scientificNameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let dateLabel = UILabel()
    private let localityLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detalhe da observação"
        configureView()
        renderObservation()
    }

    private func configureView() {
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        commonNameLabel.font = .preferredFont(forTextStyle: .title2)
        commonNameLabel.numberOfLines = 0
        scientificNameLabel.font = .preferredFont(forTextStyle: .subheadline)
        scientificNameLabel.textColor = .secondaryLabel
        categoryLabel.numberOfLines = 0
        dateLabel.numberOfLines = 0
        localityLabel.numberOfLines = 0
        [categoryLabel, dateLabel, localityLabel].forEach { $0.font = .preferredFont(forTextStyle: .body) }

        let stack = UIStackView(arrangedSubviews: [commonNameLabel, scientificNameLabel, categoryLabel, dateLabel, localityLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            imageView.heightAnchor.constraint(equalToConstant: 220),
            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func renderObservation() {
        guard let observation else {
            commonNameLabel.text = "Observação indisponível"
            scientificNameLabel.text = "Volte à lista e selecione uma observação."
            return
        }
        commonNameLabel.text = observation.displayName
        scientificNameLabel.text = observation.taxon?.name ?? "Nome científico não informado"
        categoryLabel.text = "Categoria: \(observation.taxon?.iconicTaxonName ?? "Não informada")"
        dateLabel.text = "Data: \(observation.observedOn ?? "Não informada")"
        if let coordinate = observation.coordinates {
            localityLabel.text = String(format: "Localidade: %.4f, %.4f", coordinate.latitude, coordinate.longitude)
        } else {
            localityLabel.text = "Localidade: não informada"
        }
        guard let url = observation.taxon?.defaultPhoto?.mediumURL else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.imageView.image = image }
        }.resume()
    }
}
