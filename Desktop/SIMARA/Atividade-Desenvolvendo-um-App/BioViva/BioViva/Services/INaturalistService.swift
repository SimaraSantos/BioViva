import Foundation

enum INaturalistService {
    private enum ServiceError: Error {
        case invalidURL
        case invalidResponse
        case unacceptableStatusCode(Int)
    }

    static func observationsRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.inaturalist.org"
        components.path = "/v1/observations"
        components.queryItems = [
            URLQueryItem(name: "place_id", value: "6878"),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "order_by", value: "observed_on")
        ]

        guard let url = components.url else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        return request
    }

    static func loadObservations(
        session: URLSession = .shared,
        completion: @escaping (Result<[INaturalistObservation], Error>) -> Void
    ) {
        let result: Result<URLRequest, Error>
        do {
            result = .success(try observationsRequest())
        } catch {
            result = .failure(error)
        }

        switch result {
        case .failure(let error):
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        case .success(let request):
            session.dataTask(with: request) { data, response, error in
                let result: Result<[INaturalistObservation], Error>

                if let error {
                    result = .failure(error)
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200, let data {
                    do {
                        result = .success(try JSONDecoder().decode(ObservationsResponse.self, from: data).results)
                    } catch {
                        result = .failure(error)
                    }
                } else if let response = response as? HTTPURLResponse {
                    result = .failure(ServiceError.unacceptableStatusCode(response.statusCode))
                } else {
                    result = .failure(ServiceError.invalidResponse)
                }

                DispatchQueue.main.async {
                    completion(result)
                }
            }.resume()
        }
    }
}
