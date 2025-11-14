import Foundation

class KonnekService {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    static var apiConfig = ApiConfig()
    
    func getConfig(
        clientIdValue: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let platformData = "ios"
        
        let apiService = ApiConfig().provideApiService()
        apiService.getConfig(
            clientId: clientIdValue,
            platform: platformData,
            completion: completion
        )
    }
}
