import Foundation

class JSONHelper {
    func jsonStringToDict(_ jsonString: String) -> [String: Any]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return dictionary
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    func parseJSONString<T>(_ jsonString: String, as type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let result = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return result as? T
        } catch {
            return nil
        }
    }
    
    func dictionaryToJsonString(_ dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
