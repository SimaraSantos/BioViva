import CoreLocation

struct ObservationsResponse: Codable {
    let results: [INaturalistObservation]
}

struct INaturalistObservation: Codable {
    let id: Int
    let observedOn: String?
    let taxon: Taxon?
    let geojson: GeoJSON?

    var displayName: String {
        taxon?.preferredCommonName ?? taxon?.name ?? "Especie nao identificada"
    }

    var coordinates: CLLocationCoordinate2D? {
        guard let values = geojson?.coordinates, values.count == 2 else {
            return nil
        }

        let coordinate = CLLocationCoordinate2D(latitude: values[1], longitude: values[0])
        return CLLocationCoordinate2DIsValid(coordinate) ? coordinate : nil
    }

    enum CodingKeys: String, CodingKey {
        case id
        case observedOn = "observed_on"
        case taxon
        case geojson
    }

    struct Taxon: Codable {
        let preferredCommonName: String?
        let name: String?
        let iconicTaxonName: String?
        let defaultPhoto: Photo?

        enum CodingKeys: String, CodingKey {
            case preferredCommonName = "preferred_common_name"
            case name
            case iconicTaxonName = "iconic_taxon_name"
            case defaultPhoto = "default_photo"
        }
    }

    struct Photo: Codable {
        let mediumURL: URL?

        enum CodingKeys: String, CodingKey {
            case mediumURL = "medium_url"
        }
    }

    struct GeoJSON: Codable {
        let coordinates: [Double]?
    }
}
