import UIKit
import MapKit

final class MapViewController: UIViewController {
    private let mapView = MKMapView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mapa"
        configureView()
        showObservations()
    }

    private func configureView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        emptyLabel.text = "Não há observações com localização para mostrar no mapa."
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func showObservations() {
        let annotations = ObservationStore.shared.observations.compactMap { observation -> MKPointAnnotation? in
            guard let coordinate = observation.coordinates else { return nil }
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = observation.displayName
            annotation.subtitle = observation.observedOn ?? observation.taxon?.iconicTaxonName
            return annotation
        }
        mapView.addAnnotations(annotations)
        emptyLabel.isHidden = !annotations.isEmpty
        guard !annotations.isEmpty else { return }
        mapView.showAnnotations(annotations, animated: false)
    }
}
