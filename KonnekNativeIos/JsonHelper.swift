import Foundation

class JSONHelper {
    // Basic function that returns [String: Any]
    func jsonStringToDict(_ jsonString: String) -> [String: Any]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
//            print("Error: Unable to convert string to data")
            return nil
        }
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return dictionary
            } else {
//                print("Error: JSON is not a dictionary")
                return nil
            }
        } catch {
//            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }

    // Generic function with error handling
    func parseJSONString<T>(_ jsonString: String, as type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else {
//            print("Error: Unable to convert string to data")
            return nil
        }
        
        do {
            let result = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return result as? T
        } catch {
//            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    func dictionaryToJsonString(_ dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8)
        } catch {
//            print("Dictionary to JSON conversion error: \(error.localizedDescription)")
            return nil
        }
    }
}
