import Foundation

protocol ConnectionManagerProtocol {
    func startDataTask(with url: URL, completion: ((Bool, Data?) -> Void)?)
}

class ConnectionManager: ConnectionManagerProtocol {
    private let sharedSession = URLSession.shared
    private let queue = DispatchQueue(label: "yuanlu.ZenlyUserViewer-connectioinManager")
    
    func startDataTask(with url: URL, completion: ((Bool, Data?) -> Void)?) {
        queue.async {
            self.sharedSession.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    if let data = data {
                        completion?(true, data)
                    } else {
                        print("Warning: Data task failed with no data and no error, response: \(response)")
                        completion?(false, nil)
                    }
                } else {
                    print("Error: Data task failed with error: \(error)), response: \(response)")
                    completion?(false, nil)
                }
            }.resume()
        }
    }
}
