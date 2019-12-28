import Foundation
y
enum PersonImageType: String {
    case thumbnail = "thumbnail"
    case meidum = "medium"
    case large = "large"
}

class Person: Codable {
    let uuid: String
    let userName: String
    let firstName: String
    let lastName: String
    let gender: String
    let email: String
    let cellPhone: String
    let age: Int
    var photoUrlThumbnail: String
    var photoUrlMedium: String
    var photoUrlLarge: String

    var localPhotoUrlThumbnail: URL? = nil
    var localPhotoUrlMedium: URL? = nil
    var localPhotoUrlLarge: URL? = nil

    init(
        uuid: String,
        userName: String,
        firstName: String,
        lastName: String,
        gender: String,
        email: String,
        cellPhone: String,
        age: Int,
        photoUrlThumbnail: String,
        photoUrlMeidum: String,
        photoUrlLarge: String
    ) {
        self.uuid = uuid
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.email = email
        self.cellPhone = cellPhone
        self.age = age
        self.photoUrlThumbnail = photoUrlThumbnail
        self.photoUrlMedium = photoUrlMeidum
        self.photoUrlLarge = photoUrlLarge
    }
}

// MARK: - utility methods

extension Person: Equatable {
    static func == (_ lhs: Person, _ rhs: Person) -> Bool {
        if lhs.uuid == rhs.uuid
            && lhs.userName == rhs.userName
            && lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.gender == rhs.gender
            && lhs.email == rhs.email
            && lhs.cellPhone == rhs.cellPhone
            && lhs.age == rhs.age
            && lhs.photoUrlThumbnail == rhs.photoUrlThumbnail
            && lhs.photoUrlMedium == rhs.photoUrlMedium
            && lhs.photoUrlLarge == rhs.photoUrlLarge {
            return true
        } else {
            return false
        }
    }
}

// MARK: - printable conformance

extension Person: CustomStringConvertible {
    var description: String {
        var description = ""
        description += "uuid: \(uuid)\n"
        description += "userName: \(userName)\n"
        description += "firstName: \(firstName)\n"
        description += "lastName: \(lastName)\n"
        description += "gender: \(gender)\n"
        description += "email: \(email)\n"
        description += "cellPhone: \(cellPhone)\n"
        description += "age: \(age)\n"
        description += "photoUrlThumbnail: \(photoUrlThumbnail)\n"
        description += "photoUrlMedium: \(photoUrlMedium)\n"
        description += "photoUrlLarge: \(photoUrlLarge)\n"
        description += "localPhotoUrlThumbnail: \(localPhotoUrlThumbnail)\n"
        description += "localPhotoUrlMedium: \(localPhotoUrlMedium)\n"
        description += "localPhotoUrlLarge: \(localPhotoUrlLarge)\n"

        return description
    }
}

