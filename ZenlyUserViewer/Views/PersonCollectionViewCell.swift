import UIKit

class PersonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var firstNameOutlet: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    var person: Person? = nil
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.firstNameOutlet.text = ""
        self.imageOutlet.image = Constants.loadingImage
    }
    
    func setupCell(with person: Person) {
        self.person = person
        
        DispatchQueue.global().async {
            var image: UIImage? = nil
            if let photoUrl = person.localPhotoUrlThumbnail {
                let key = PersonManager.getImageCacheKey(with: person.uuid, imageType: .thumbnail) as NSString
                if let cachedImage = PersonManager.imageCache.object(forKey: key) {
                    image = cachedImage
                } else {
                    // if doesn't exist in cache, try to load from disk
                    do {
                        try image = UIImage(data: Data(contentsOf: photoUrl))
                    } catch {
                        // if fails, load placeHolder
                        image = Constants.placeHolderImage
                    }
                }
            } else {
                // use loading image
                image = Constants.loadingImage
            }
            
            DispatchQueue.main.async {
                self.firstNameOutlet.numberOfLines = 0
                self.firstNameOutlet.text = person.firstName
                self.firstNameOutlet.sizeToFit()
                
                self.imageOutlet.image = image
            }
        }
    }
    
    func reload() {
        guard let person = person else {
            return
        }
        
        setupCell(with: person)
    }
}
