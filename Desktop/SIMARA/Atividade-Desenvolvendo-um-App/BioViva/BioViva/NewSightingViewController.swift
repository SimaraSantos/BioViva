import UIKit
import CoreData
import CoreLocation

final class NewSightingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    private static let maximumLocationAge: TimeInterval = 60
    private let nameField = UITextField()
    private let imageView = UIImageView()
    private let photoButton = UIButton(type: .system)
    private let locationLabel = UILabel()
    private let locationButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let locationManager = CLLocationManager()
    private var selectedImage: UIImage?
    private var selectedLocation: CLLocation?
    private var isAwaitingLocationAuthorization = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Novo avistamento"
        locationManager.delegate = self
        configureView()
    }

    private func configureView() {
        nameField.placeholder = "Nome da espécie"
        nameField.borderStyle = .roundedRect
        nameField.autocapitalizationType = .words
        nameField.autocorrectionType = .yes

        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        configure(button: photoButton, title: "Escolher foto", image: "photo.on.rectangle")
        configure(button: locationButton, title: "Usar localização atual", image: "location")
        configure(button: saveButton, title: "Salvar avistamento", image: "checkmark.circle")
        photoButton.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(requestCurrentLocation), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveSighting), for: .touchUpInside)

        locationLabel.text = "Localização: não selecionada"
        locationLabel.font = .preferredFont(forTextStyle: .footnote)
        locationLabel.numberOfLines = 0
        locationLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [nameField, imageView, photoButton, locationLabel, locationButton, saveButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            photoButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            locationButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            saveButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
    }

    private func configure(button: UIButton, title: String, image: String) {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = title
        configuration.image = UIImage(systemName: image)
        configuration.imagePadding = 8
        configuration.cornerStyle = .medium
        button.configuration = configuration
    }

    @objc private func selectPhoto() {
        let alert = UIAlertController(title: "Foto do avistamento", message: "Escolha a origem da foto.", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Câmera", style: .default) { [weak self] _ in self?.presentPicker(sourceType: .camera) })
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Biblioteca de Fotos", style: .default) { [weak self] _ in self?.presentPicker(sourceType: .photoLibrary) })
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = photoButton
            popover.sourceRect = photoButton.bounds
        }
        present(alert, animated: true)
    }

    private func presentPicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showAlert(title: "Fonte indisponível", message: "Esta fonte de foto não está disponível neste dispositivo.")
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func requestCurrentLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            isAwaitingLocationAuthorization = true
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationLabel.text = "Obtendo localização atual…"
            locationManager.requestLocation()
        case .denied, .restricted:
            showAlert(title: "Localização indisponível", message: "Permita o acesso à localização nos Ajustes para registrar a posição do avistamento.")
        @unknown default:
            showAlert(title: "Localização indisponível", message: "Não foi possível usar sua localização.")
        }
    }

    @objc private func saveSighting() {
        let name = nameField.text ?? ""
        if let error = NewSightingValidator.error(for: name, hasImage: selectedImage != nil) {
            let message = error == .missingName ? "Informe o nome da espécie." : "Adicione uma foto antes de salvar."
            showAlert(title: "Avistamento incompleto", message: message)
            return
        }
        guard let location = selectedLocation, isUsable(location: location) else {
            invalidateSelectedLocation()
            showLocationRequiredAlert()
            return
        }
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8),
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            showAlert(title: "Não foi possível salvar", message: "A foto ou o armazenamento local não estão disponíveis.")
            return
        }
        let container = appDelegate.persistentContainer
        guard appDelegate.isPersistentStoreAvailable else {
            showAlert(title: "Não foi possível salvar", message: "A foto ou o armazenamento local não estão disponíveis.")
            return
        }
        let context = container.viewContext
        let sighting = NSEntityDescription.insertNewObject(forEntityName: "LocalSighting", into: context)
        sighting.setValue(name.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "name")
        sighting.setValue(imageData, forKey: "imageData")
        sighting.setValue(location.coordinate.latitude, forKey: "latitude")
        sighting.setValue(location.coordinate.longitude, forKey: "longitude")
        sighting.setValue(Date(), forKey: "createdAt")
        do {
            try context.save()
            resetForm()
            showAlert(title: "Avistamento salvo", message: "Seu registro foi salvo neste dispositivo.")
        } catch {
            context.rollback()
            showAlert(title: "Não foi possível salvar", message: "Tente novamente em alguns instantes.")
        }
    }

    private func resetForm() {
        nameField.text = nil
        selectedImage = nil
        selectedLocation = nil
        imageView.image = UIImage(systemName: "photo")
        locationLabel.text = "Localização: não selecionada"
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        selectedImage = info[.originalImage] as? UIImage
        imageView.image = selectedImage ?? UIImage(systemName: "photo")
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAwaitingLocationAuthorization = false
            manager.requestLocation()
        case .denied, .restricted:
            guard isAwaitingLocationAuthorization else { return }
            isAwaitingLocationAuthorization = false
            locationLabel.text = "Localização: acesso não permitido"
            showAlert(title: "Localização indisponível", message: "Permita o acesso à localização nos Ajustes e toque em “Usar localização atual” para registrar a posição do avistamento.")
        case .notDetermined:
            break
        @unknown default:
            isAwaitingLocationAuthorization = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationLabel.text = "Localização: não disponível"
            return
        }
        guard isUsable(location: location) else {
            invalidateSelectedLocation()
            return
        }
        selectedLocation = location
        locationLabel.text = String(format: "Localização: %.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationLabel.text = "Localização: não disponível"
        showAlert(title: "Localização indisponível", message: "Não foi possível obter sua localização atual.")
    }

    private func isUsable(location: CLLocation) -> Bool {
        let age = Date().timeIntervalSince(location.timestamp)
        return CLLocationCoordinate2DIsValid(location.coordinate)
            && location.horizontalAccuracy >= 0
            && age >= 0
            && age <= Self.maximumLocationAge
    }

    private func invalidateSelectedLocation() {
        selectedLocation = nil
        locationLabel.text = "Localização: atualize sua localização para continuar"
    }

    private func showLocationRequiredAlert() {
        showAlert(title: "Localização necessária", message: "Use “Usar localização atual” e permita o acesso à localização antes de salvar o avistamento.")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
