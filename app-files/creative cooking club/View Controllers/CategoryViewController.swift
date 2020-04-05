//  creative Cooking Club
//

import UIKit

// Scroll view with all categories at the top of the recipe screen
class CategoryViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    private var selectedCategoryIndex: Int = 0
    private var didUpdateSelectedCategory: Bool = false
    var didSelectCategory: ((_ category: Category) -> Void)?

    /// Refresh view when starting
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didUpdateSelectedCategory {
            collectionView.reloadData()
            didUpdateSelectedCategory = true
        }
    }
}

// MARK: - Display all categories in a scroll/collection view
extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CategoryCollectionViewCell {
            cell.setSelected(indexPath.item == selectedCategoryIndex)
            cell.setCategory(name: Category.allCases[indexPath.row].rawValue)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath.item
        collectionView.visibleCells.forEach { (cell) in
            (cell as? CategoryCollectionViewCell)?.setSelected(false)
        }
        (collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell)?.setSelected(true)
        didSelectCategory?(Category.allCases[indexPath.row])
    }
}
