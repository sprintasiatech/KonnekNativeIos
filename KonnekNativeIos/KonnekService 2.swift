//
//  KonnekService.swift
//  KonnekNativeIos
//
//  Created by Fauzan Akmal Mahdi on 01/10/25.
//

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
        KonnekFlutterPlugin.clientId = clientIdValue
        
        let apiService = ApiConfig().provideApiService()
        apiService.getConfig(
            clientId: clientIdValue,
            platform: platformData,
            completion: completion
        )
    }
}
