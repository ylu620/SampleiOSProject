import UIKit

// Note: potential improvement, find a better owner for these constants,
// or split them up when they get big enough
struct Constants {
    // declare static here to avoid image being purged from cache for better performance
    static let placeHolderImage = UIImage(named: "placeholder.png")
    static let loadingImage = UIImage(named: "loading.png")

    // segues
    static let rootToPersonCollectionVCSegue = "rootToPersonCollectionVC"
    static let collectionViewCellToDetailVCSegue = "collectionViewCellToDetailVC"

    // urls
    static let userListUrl = "https://randomuser.me/api/?results=200" // pick 200 for now, potentially expose this for users to set
    
    // sizes
    static let collectionViewSize = CGSize(width: 120, height: 120)
}


class ViewController: UIViewController {
    private let manager = PersonManager(
        connectionManager: ConnectionManager(),
        personStorage: PersonStorage()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewDidDisappear(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Constants.rootToPersonCollectionVCSegue) {
            if let des = segue.destination as? PersonCollectionViewController {
                des.manager = manager
            }
        }
    }
}
