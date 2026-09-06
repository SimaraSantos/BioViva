import Foundation

/// Shared, in-memory source of truth for the observations loaded in this app session.
final class ObservationStore {
    static let shared = ObservationStore()

    private(set) var observations: [INaturalistObservation] = []

    private init() {}

    func replace(with observations: [INaturalistObservation]) {
        self.observations = observations
    }

    func observation(withID id: Int) -> INaturalistObservation? {
        observations.first { $0.id == id }
    }

    func removeAll() {
        observations.removeAll()
    }
}
