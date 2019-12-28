import UIKit

class PersonCollectionViewController: UICollectionViewController {
    // MARK: UIActions
    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        manager?.reloadPersonList(completion: { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        })
    }
    
    private let reuseIdentifier = "reuseCollectionViewCell"
    var manager: PersonManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let uwManager = manager {
            uwManager.delegate = self
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.collectionViewCellToDetailVCSegue {
            if let des = segue.destination as? PersonDetailViewController {
                guard let uwManager = manager,
                    let indexPaths = collectionView.indexPathsForSelectedItems else {
                    return
                }

                let person = uwManager.getAllPersons()[indexPaths.first!.row]
                des.person = person

                uwManager.downloadImageIfNeeded(for: person, of: .large) { (success) in
                    if success {
                        des.reloadImage()
                    }
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let uwManager = manager else {
            return 0
        }
        return uwManager.getAllPersons().count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PersonCollectionViewCell
    
        if cell == nil {
            cell = PersonCollectionViewCell()
        }
        
        if let uwManager = manager, let person = uwManager.getAllPersons()[safe: indexPath.row] {
            cell?.setupCell(with: person)

            // download image for cell if needed
            uwManager.downloadImageIfNeeded(
                for: person,
                of: .thumbnail,
                completion: { success in
                    // reload cell to update image
                    if success {
                        cell?.reload()
                    }
                }
            )
        }
    
        return cell!
    }

}

// MARK: - UICollectionViewDelegateFlowLayout delegate conformance

extension PersonCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    
    return Constants.collectionViewSize
  }
}

// MARK: - PersonManagerDelegateProtocol conformance

extension PersonCollectionViewController: PersonManagerDelegateProtocol {
    func reloadViewAll() {
        if Thread.isMainThread {
            collectionView.reloadData()
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    func reloadView(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if Thread.isMainThread {
            collectionView.reloadItems(at: [indexPath])
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}
