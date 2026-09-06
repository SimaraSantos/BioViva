import Foundation

enum NewSightingValidationError: Equatable { case missingName, missingImage }

enum NewSightingValidator {
    static func error(for name: String, hasImage: Bool) -> NewSightingValidationError? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return .missingName }
        if !hasImage { return .missingImage }
        return nil
    }
}
