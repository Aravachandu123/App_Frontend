import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .noData: return "No data received from the server."
        case .decodingError: return "Failed to decode the response."
        case .serverError(let message): return message
        }
    }
}

struct EmptyResponse: Codable {}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func request<T: Decodable>(endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void) {
        guard let request = endpoint.urlRequest else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.serverError("Invalid response type")))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // For debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response for \(endpoint.path): \(responseString)")
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                    completion(.failure(NetworkError.decodingError))
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(NetworkError.decodingError))
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(NetworkError.decodingError))
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(NetworkError.decodingError))
                } catch {
                    print("error: ", error)
                    completion(.failure(NetworkError.decodingError))
                }
            } else {
                // Try to parse error message from server
                if let errorDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = errorDict["error"] as? String {
                    completion(.failure(NetworkError.serverError(errorMessage)))
                } else {
                    completion(.failure(NetworkError.serverError("Status code HTTP \(httpResponse.statusCode)")))
                }
            }
        }
        
        task.resume()
    }
}
