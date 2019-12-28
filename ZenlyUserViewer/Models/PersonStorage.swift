import Foundation

protocol PersonStorageProtocol {
    func getAllPersons() -> [Person]
    func savePersons(_ persons: [Person])
    func saveImage(data: Data, type: PersonImageType, for id: String) -> URL?
    func removeAllResources(for id: String)
    func removeAllResources()
    func removeResources(of type: PersonImageType, for id: String)
    func removeCurrentPersonList()
    func fileExistInStorage() -> Bool
}

class PersonStorage: PersonStorageProtocol {
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let fileManager = FileManager.default
    private var persons = [Person]()
    private var loaded = false
    private let queue = DispatchQueue(label: "yuanlu.ZenlyUserViewer-personStorage")
    
    func getAllPersons() -> [Person] {
        return queue.sync {
            if loaded {
                return persons
            } else {
                loadPersonsFromFile()
                return persons
            }
        }
    }

    func savePersons(_ persons: [Person]) {
        return queue.async {
            // sort by first name
            let sorted = persons.sorted { $0.firstName < $1.firstName }
            do {
                let data = try self.jsonEncoder.encode(sorted)
                try data.write(to: self.personListUrl(), options: .atomic)
                self.persons = persons
            } catch {
                print("Error: failed to save persons to file due to error \(error)")
            }
        }
    }

    func saveImage(data: Data, type: PersonImageType, for id: String) -> URL? {
        return queue.sync {
            let dirPath = personImageDirUrl(for: id)
            let imageFileUrl = dirPath.appendingPathComponent(type.rawValue)
            do {
                try data.write(to: imageFileUrl)
            } catch {
                print("Error: failed to save image to file due to error \(error)")
                return nil
            }

            return imageFileUrl
        }
    }

    func removeAllResources(for id: String) {
        queue.async {
            do {
                let dirUrl = self.personImageDirUrl(for: id)
                try self.fileManager.removeItem(at: dirUrl)
            } catch {
                print("Error: failed to remove resource folder for \(id) due to error \(error)")
            }
        }
    }
    
    func removeAllResources() {
        queue.async {
            do {
                let dirUrl = self.personImageParentDirUrl()
                try self.fileManager.removeItem(at: dirUrl)
            } catch {
                print("Error: failed to delete resource folder for images")
            }
        }
    }

    func removeResources(of type: PersonImageType, for id: String) {
        queue.async {
            let dirUrl = self.personImageDirUrl(for: id)
            var imageFileUrl: URL
            imageFileUrl = dirUrl.appendingPathComponent(type.rawValue)
            do {
                try self.fileManager.removeItem(at: imageFileUrl)
            } catch {
                print("Error: failed to remove resources for \(id) due to error \(error)")
            }
        }
    }
    
    func removeCurrentPersonList() {
        queue.async {
            do {
                let url = self.personListUrl()
                try self.fileManager.removeItem(at: url)
                self.persons = []
                self.loaded = false
            } catch {
                print("Error: failed to delete person list from disk")
            }
        }
    }
    
    func fileExistInStorage() -> Bool {
        return fileManager.fileExists(atPath: personListUrl().path)
    }

    // MARK: private mthods

    private func loadPersonsFromFile() {
        do {
            let url = personListUrl()
            if fileManager.fileExists(atPath: url.path) {
                let jsonData = try Data(contentsOf: url)
                let tempPersons = try jsonDecoder.decode([Person].self, from: jsonData)

                persons = tempPersons
                loaded = true
            } else {
                loaded = false
            }
        } catch {
            print("Error: failed to load persons from file due to error \(error)")
        }
    }
}

// MARK: - utility methods

extension PersonStorage {
    private func personListUrl() -> URL {
        return URL(fileURLWithPath: pathToDocumentsDir()).appendingPathComponent("personList.json")
    }

    private func personImageDirUrl(for personId: String) -> URL {
        let url = URL(fileURLWithPath: pathToDocumentsDir()).appendingPathComponent("PersonImages/\(personId)")

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: [:]
                )
            } catch {
                print("Warn: failed to create resource folder for \(personId) due to error \(error)")
            }
        }

        return url
    }
    
    private func personImageParentDirUrl() -> URL {
        let url = URL(fileURLWithPath: pathToDocumentsDir()).appendingPathComponent("PersonImages")

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: [:]
                )
            } catch {
                print("Warn: failed to create resource folder for images")
            }
        }

        return url
    }

    private func pathToDocumentsDir() -> String {
        return NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true)[0]
    }
}
