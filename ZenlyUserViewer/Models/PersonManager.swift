import Foundation
import UIKit

protocol PersonManagerDelegateProtocol: AnyObject {
    func reloadViewAll()
    func reloadView(at index: Int)
}

// protocol created for mocking purposes
protocol PersonManagerProtocol {
    func save(Persons: [Person])
    func getAllPersons() -> [Person]
    func getPerson(with id: String) -> Person?
    func reloadPersonList(completion: ((Bool) -> Void)?)
    func downloadImageIfNeeded()
}

class PersonManager {
    static let imageCache = NSCache<NSString, UIImage>()
    
    private let connectionManager: ConnectionManagerProtocol
    private let personStorage: PersonStorageProtocol
    private let queue = DispatchQueue(label: "yuanlu.ZenlyUserViewer-PersonManager")
    
    weak var delegate: PersonManagerDelegateProtocol? = nil

    init(
        connectionManager: ConnectionManagerProtocol,
        personStorage: PersonStorageProtocol
    ) {
        self.connectionManager = connectionManager
        self.personStorage = personStorage
        
        loadPersonListIfNeeded()
    }

    func save(persons: [Person]) {
        queue.async {
            self.personStorage.savePersons(persons)
        }
    }

    func getAllPersons() -> [Person] {
        return queue.sync {
            return personStorage.getAllPersons()
        }
    }

    func getPerson(with id: String) -> Person? {
        return queue.sync {
            return personStorage.getAllPersons().filter { $0.uuid == id }.first
        }
    }

    func reloadPersonList(completion: ((Bool) -> Void)?) {
        queue.async {
            guard let url = URL(string: Constants.userListUrl) else {
                print("Error: unable to generate URL for downloading user list")
                return
            }
            
            self.personStorage.removeAllResources()
            self.personStorage.removeCurrentPersonList()
            
            self.connectionManager.startDataTask(with: url) { [weak self] (success, data) in
                if success, let uwData = data {
                    self?.processDownloadedUserList(data: uwData)
                    completion?(success)
                }
            }
        }
    }

    func downloadImageIfNeeded(
        for person: Person,
        of type: PersonImageType,
        completion: @escaping (Bool) -> Void
    ) {
        queue.async {
            var url: URL? = nil

            switch type {
            case .thumbnail:
                if person.localPhotoUrlThumbnail == nil {
                    url = URL(string: person.photoUrlThumbnail)
                }
            case .meidum:
                if person.localPhotoUrlMedium == nil {
                    url = URL(string: person.photoUrlMedium)
                }
            case .large:
                if person.localPhotoUrlLarge == nil {
                    url = URL(string: person.photoUrlLarge)
                }
            default:
                // invalid
                print("Warning: shouldn't be here when handlng imnage downloading")
            }
            
            guard let uwUrl = url  else {
                completion(false)
                return
            }
            
            self.connectionManager.startDataTask(with: uwUrl, completion: { [weak self] (success, data) in
                if success, let uwData = data {
                    self?.processDownloadedUserImage(
                        data: uwData,
                        type: type,
                        for: person.uuid
                    )
                }
                completion(success)
            })
        }
    }

    // MARK: private methods
    
    private func loadPersonListIfNeeded() {
        // check if file exists in db, if not pull from service
        if !personStorage.fileExistInStorage() {
            reloadPersonList(completion: nil)
        }
    }
    
    private func processDownloadedUserList(data: Data) {
        var jsonObject: Any? = nil
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print("Error: JSON data unserializing failed: \(error)")
        }

        guard let jsonDict = jsonObject as? [String: Any],
            let personsInJson = jsonDict["results"] as? [[String: Any]]
        else {
            print("Error: Unable to parse read 'results' in JSON")
            return
        }

        var updatedPersons = [Person]()
        for personJson in personsInJson {
            if let person = parseJsonIntoPerson(json: personJson) {
                updatedPersons.append(person)
            } else {
                print("Error: Parsing failed for person: \(personJson)")
            }
        }

        personStorage.savePersons(updatedPersons)
        delegate?.reloadViewAll()
    }

    private func processDownloadedUserImage(
        data: Data,
        type: PersonImageType,
        for uuid: String
    ) {
        guard let person = getPerson(with: uuid) else {
            return
        }
        
        // save to cache
        if let image = UIImage(data: data) {
            let key = PersonManager.getImageCacheKey(with: uuid, imageType: type) as NSString
            PersonManager.imageCache.setObject(image, forKey: key)
        }
        let url = personStorage.saveImage(data: data, type: type, for: uuid)
        
        switch type {
        case .thumbnail:
            person.localPhotoUrlThumbnail = url
        case .meidum:
            person.localPhotoUrlMedium = url
        case .large:
            person.localPhotoUrlLarge = url
        default:
            // invalid
            print("Warning: shouldn't be here")
        }

        // save cache to disk
        personStorage.savePersons(getAllPersons())
    }
}

// MARK: - utility methods

extension PersonManager {
    private func parseJsonIntoPerson(json: [String: Any]) -> Person? {
        guard
            let login = json["login"] as? [String: Any],
            let uuid = login["uuid"] as? String,
            let userName = login["username"] as? String,
            let name = json["name"] as? [String: Any],
            let firstName = name["first"] as? String,
            let lastName = name["last"] as? String,
            let gender = json["gender"] as? String,
            let emailAddress = json["email"] as? String,
            let cellPhone = json["cell"] as? String,
            let dob = json["dob"] as? [String: Any],
            let age = dob["age"] as? Int,
            let pictures = json["picture"] as? [String: Any],
            let thumbnailPic = pictures["thumbnail"] as? String,
            let mediumPic = pictures["medium"] as? String,
            let largePic = pictures["large"] as? String
        else {
            print("Error: Unable to parse Json: \(json)")
            return nil
        }
        
        let person = Person(
            uuid: uuid,
            userName: userName,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            email: emailAddress,
            cellPhone: cellPhone,
            age: age,
            photoUrlThumbnail: thumbnailPic,
            photoUrlMeidum: mediumPic,
            photoUrlLarge: largePic
        )

        return person
    }
    
    static func getImageCacheKey(with uuid: String, imageType: PersonImageType) -> String {
        return uuid + "-" + imageType.rawValue
    }
}

// MARK: - Collection extension

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
