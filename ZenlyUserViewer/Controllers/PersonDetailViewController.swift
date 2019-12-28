import UIKit

class PersonDetailViewController: UIViewController {
    // MARK: UI outlets
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var nameLabelOutlet: UILabel!
    @IBOutlet weak var phoneNumLabelOutlet: UILabel!
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var ageLabelOutlet: UILabel!
    @IBOutlet weak var usernameLabelOutlet: UILabel!
    @IBOutlet weak var genderLabelOutlet: UILabel!
    // MARK: UI actions
    @IBAction func backButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    var person: Person? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if Thread.isMainThread {
            setupView()
        } else {
            DispatchQueue.main.async {
                self.setupView()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        if Thread.isMainThread {
            clearView()
        } else {
            DispatchQueue.main.async {
                self.clearView()
            }
        }
    }

    func reloadImage() {
        guard let uwPerson = person else {
            return
        }

        // load large -> if not load small -> if not load placeholder
        DispatchQueue.global().async {
            var image: UIImage? = nil
            
            if let largePhotoUrl = uwPerson.localPhotoUrlLarge {
                let largeKey = PersonManager.getImageCacheKey(with: uwPerson.uuid, imageType: .large) as NSString
                if let cachedLarge = PersonManager.imageCache.object(forKey: largeKey)  {
                    image = cachedLarge
                } else {
                    try? image = UIImage(data: Data(contentsOf: largePhotoUrl))
                }
            } else if let smallPhotoUrl = uwPerson.localPhotoUrlThumbnail {
                let thumbnailKey = PersonManager.getImageCacheKey(with: uwPerson.uuid, imageType: .thumbnail) as NSString
                if let cachedThumbnail = PersonManager.imageCache.object(forKey: thumbnailKey)  {
                    image = cachedThumbnail
                } else {
                    try? image = UIImage(data: Data(contentsOf: smallPhotoUrl))
                }
            } else {
                image = Constants.placeHolderImage
            }

            DispatchQueue.main.async {
                self.imageViewOutlet.image = image
            }
        }
    }

    private func setupView() {
        guard let person = self.person else {
            return
        }

        nameLabelOutlet.numberOfLines = 0
        nameLabelOutlet.text = person.firstName + " " + person.lastName
        nameLabelOutlet.sizeToFit()

        phoneNumLabelOutlet.numberOfLines = 0
        phoneNumLabelOutlet.text = person.cellPhone
        phoneNumLabelOutlet.sizeToFit()

        emailLabelOutlet.numberOfLines = 0
        emailLabelOutlet.text = person.email
        emailLabelOutlet.sizeToFit()

        ageLabelOutlet.numberOfLines = 0
        ageLabelOutlet.text = "\(person.age)"
        ageLabelOutlet.sizeToFit()

        usernameLabelOutlet.numberOfLines = 0
        usernameLabelOutlet.text = person.userName
        usernameLabelOutlet.sizeToFit()

        genderLabelOutlet.numberOfLines = 0
        genderLabelOutlet.text = person.gender
        genderLabelOutlet.sizeToFit()

        reloadImage()
    }

    private func clearView() {
        imageViewOutlet.image = Constants.loadingImage
        nameLabelOutlet.text = nil
        phoneNumLabelOutlet.text = nil
        emailLabelOutlet.text = nil
        ageLabelOutlet.text = nil
        usernameLabelOutlet.text = nil
        genderLabelOutlet.text = nil
        person = nil
    }
}
