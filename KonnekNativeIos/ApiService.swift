import Foundation

class ApiService {
    private let session: URLSession
    private let baseUrl: String
    
    init(session: URLSession = .shared, baseUrl: String) {
        self.session = session
        self.baseUrl = baseUrl
    }
    
    func getConfig(
        clientId: String,
        platform: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let urlString = "\(baseUrl)channel/config/\(clientId)/\(platform)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        perform(request: request, completion: completion)
    }
    
    private func perform(request: URLRequest, completion: @escaping (Result<String, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
            }
            
            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
            }
            
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return completion(.failure(NSError(domain: "Invalid UTF-8 encoding", code: -3, userInfo: nil)))
            }
            
            completion(.success(jsonString))
        }.resume()
    }
}
