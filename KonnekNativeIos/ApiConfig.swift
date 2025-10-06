import Foundation

class ApiConfig {
    private var baseUrl = EnvironmentConfig.baseUrl()
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 120
        
        self.session = URLSession(configuration: config)
    }
    
    func provideApiService() -> ApiService {
        return ApiService(session: session, baseUrl: baseUrl)
    }
}
