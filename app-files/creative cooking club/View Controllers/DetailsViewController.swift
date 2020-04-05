//  creative Cooking Club
//

import UIKit

// This represents each section for Details screen
enum DetailsSection: String, CaseIterable {
    case title, ingredients, instructions
}

// This is the details screen where we show more details about a recipe, including the ingredients/instructions
class DetailsViewController: UIViewController {
    
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var gradientHeader: GradientView!
    @IBOutlet weak private var swipeView: UIView!
    @IBOutlet weak private var swipeViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var recipeImageView: UIImageView!
    @IBOutlet weak private var tableView: UITableView!
    var meal: Meal!
    
    /// Initial logic when the screen loads
    @available(iOS, deprecated: 9.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareHeaderStyle()
    }
    
    /// Prepare the header with the meal image and set status bar color to white
    @available(iOS, deprecated: 9.0)
    private func prepareHeaderStyle() {
        setupHeaderImage()
        favoriteButton.isSelected = meal.favorite
        gradientHeader.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.01).cgColor]
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
     
    /// Show recipe image if available or download it if necessary
    private func setupHeaderImage() {
        if let mealImage = meal.image {
            recipeImageView.image = mealImage
        } else {
            MealsManager.downloadImage(url: meal.imageURL) { (image) in
                if let headerImage = image {
                    self.meal.image = headerImage
                    DispatchQueue.main.async { self.recipeImageView.image = headerImage }
                }
            }
        }
    }
    
    /// Handle swipe up/down gesture for the list/view
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .up || sender.direction == .down {
            let priority = sender.direction == .up ? UILayoutPriority(rawValue: 999) : UILayoutPriority(rawValue: 100)
            swipeViewTopConstraint.priority = priority
            tableView.isScrollEnabled = sender.direction == .up
            tableView.setContentOffset(.zero, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.gradientHeader.alpha = sender.direction == .up ? 0.8 : 0.3
            }
        }
    }
    
    /// Add/Remove meal from favorites list
    @IBAction func favoriteAction(_ sender: UIButton) {
        meal.favorite = !meal.favorite
        sender.isSelected = !sender.isSelected
        FavoritesManager.saveMeal(meal)
    }
}

// MARK: - Display all details about a recipe, including ingredients, instructions, etc
extension DetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DetailsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = DetailsSection.allCases[indexPath.row].rawValue
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? MealDetailsTableViewCell {
            cell.configure(meal: meal)
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - When scrolling animation ends, auto-swipe down the list view
extension DetailsViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            tableView.isScrollEnabled = false
            swipeViewTopConstraint.priority = UILayoutPriority(rawValue: 100)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.gradientHeader.alpha = 0.4
            }
        }
    }
    

}
