import Foundation
@testable import ZenlyUserViewer

class ConnectionManagerMock: ConnectionManagerProtocol {
    var success = false
    var data = Data()
    
    var startDataTaskCalled = false
    func startDataTask(with url: URL, completion: ((Bool, Data?) -> Void)?) {
        startDataTaskCalled = true
        completion?(success, data)
    }
}
