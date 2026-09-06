import XCTest
@testable import BioViva

final class NewSightingValidatorTests: XCTestCase {
    func testRejectsBlankSpeciesName() {
        XCTAssertEqual(NewSightingValidator.error(for: "  ", hasImage: true), .missingName)
    }

    func testRejectsMissingPhoto() {
        XCTAssertEqual(NewSightingValidator.error(for: "Ipê-amarelo", hasImage: false), .missingImage)
    }

    func testAcceptsCompleteSighting() {
        XCTAssertNil(NewSightingValidator.error(for: "Ipê-amarelo", hasImage: true))
    }
}
