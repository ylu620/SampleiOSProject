import Foundation
@testable import ZenlyUserViewer

class PersonStorageMock: PersonStorageProtocol {
    var persons: [Person] = []
    var url = URL(string: "")
    var fileExists = false

    var getAllPersonsCalled = false
    func getAllPersons() -> [Person] {
        getAllPersonsCalled = true
        return persons
    }

    var savePersonsCalled = false
    func savePersons(_ persons: [Person]) {
        savePersonsCalled = true
        self.persons = persons
    }

    var saveImageCalled = false
    func saveImage(data: Data, type: PersonImageType, for id: String) -> URL? {
        saveImageCalled = true
        return url
    }

    var removeAllResourcesForPersonCalled = false
    func removeAllResources(for id: String) {
        removeAllResourcesForPersonCalled = true
    }

    var removeResourcesCalled = false
    func removeResources(of type: PersonImageType, for id: String) {
        removeResourcesCalled = true
    }
    
    var removeAllResourcesCalled = false
    func removeAllResources() {
        removeAllResourcesCalled = true
    }
    
    var removeCurrentPersonListCalled = false
    func removeCurrentPersonList() {
        removeCurrentPersonListCalled = true
    }
    
    var fileExistInStorageCalled = false
    func fileExistInStorage() -> Bool {
        fileExistInStorageCalled = true
        return fileExists
    }

}
