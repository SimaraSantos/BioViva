import XCTest
@testable import BioViva

final class INaturalistServiceTests: XCTestCase {
    func testRequestUsesHTTPSBrazilEndpointAndThirtyResults() throws {
        let request = try INaturalistService.observationsRequest()

        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "api.inaturalist.org")
        XCTAssertTrue(request.url?.absoluteString.contains("place_id=6878") == true)
        XCTAssertTrue(request.url?.absoluteString.contains("per_page=30") == true)
    }

    func testDecodesAnObservationWithTaxonPhotoAndCoordinates() throws {
        let data = try fixtureData(named: "observations")

        let response = try JSONDecoder().decode(ObservationsResponse.self, from: data)

        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results[0].displayName, "Onca-pintada")
        XCTAssertEqual(response.results[0].taxon?.defaultPhoto?.mediumURL?.absoluteString, "https://static.inaturalist.org/photos/123456/medium.jpg")
        XCTAssertEqual(response.results[0].coordinates?.latitude, -3.119)
        XCTAssertEqual(response.results[0].coordinates?.longitude, -55.123)
    }

    func testReturnsNilCoordinatesForMalformedCoordinateCount() throws {
        let observation = try decodeObservation(from: """
        {"id": 1, "geojson": {"coordinates": [-55.123]}}
        """)

        XCTAssertNil(observation.coordinates)
    }

    func testReturnsNilCoordinatesForOutOfRangeValues() throws {
        let observation = try decodeObservation(from: """
        {"id": 1, "geojson": {"coordinates": [-55.123, 91.0]}}
        """)

        XCTAssertNil(observation.coordinates)
    }

    private func fixtureData(named name: String) throws -> Data {
        let bundle = Bundle(for: INaturalistServiceTests.self)
        let url = try XCTUnwrap(bundle.url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func decodeObservation(from json: String) throws -> INaturalistObservation {
        try JSONDecoder().decode(INaturalistObservation.self, from: Data(json.utf8))
    }
}
