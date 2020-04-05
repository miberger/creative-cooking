//  creative Cooking Club
//

import UIKit

// View controller (screen) with recipes
class RecipesViewController: UIViewController {

    @IBOutlet weak private var statusView: StatusView!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var segmentedControlContainer: UIView!
    @IBOutlet weak private var topLayoutConstraint: NSLayoutConstraint!
    private var categoryController: CategoryViewController!

    /// Initial logic when screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Config.ScreenTitle.recipes
        FavoritesManager.didUpdateMealDetails = {
            DispatchQueue.main.async { self.collectionView.reloadData() }}
        getMealsData()
    }
    
    /// Set the status bar color to default (black color)
    @available(iOS, deprecated: 9.0)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    /// Prepare the category controller (top scroll view with all categories)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        categoryController = segue.destination as? CategoryViewController
        categoryController.didSelectCategory = { category in
            MealsManager.currentCategory = category
            self.collectionView.reloadData()
            self.getMealsData()
        }
    }
    
    /// Get meals/recipes for current/default category
    private func getMealsData() {
        statusView.isHidden = false
        statusView.configure(mode: .loading)
        segmentedControlContainer.isUserInteractionEnabled = false
        LoadingView.showLoadingView()
        MealsManager.getMeals { (success) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                self.segmentedControlContainer.isUserInteractionEnabled = true
                self.statusView.configure(mode: success ? .success : .error)
                self.statusView.isHidden = success
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - Display a collection of meals/recipes
extension RecipesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MealsManager.meals[MealsManager.currentCategory]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RecipeCollectionViewCell {
            cell.setup(meal: MealsManager.meals[MealsManager.currentCategory]![indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - Handle meal/recipe selection (navigate to Details screen)
extension RecipesViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meal = MealsManager.meals[MealsManager.currentCategory]![indexPath.row]
        let details = storyboard?.instantiateViewController(withIdentifier: "details") as! DetailsViewController
        details.meal = meal
        navigationController?.pushViewController(details, animated: true)
    }
}

// MARK: - Configure the size of meal/recipe view
extension RecipesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 18
        let height = width * 1.8
        return CGSize(width: width, height: height)
    }
}

// MARK: - Update the constraint for categories scroll view
extension RecipesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            topLayoutConstraint.constant = abs(scrollView.contentOffset.y)
        } else { topLayoutConstraint.constant = 0 }
    }
}
