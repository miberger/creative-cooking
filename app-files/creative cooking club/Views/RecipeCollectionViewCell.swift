//  creative Cooking Club
//

import UIKit

// This is the view that shows a recipe with the image on the main 'Recipes' screen
class RecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var itemImageView: UIImageView!
    @IBOutlet weak private var itemNameLabel: UILabel!
    @IBOutlet weak private var areaLabel: UILabel!
    @IBOutlet weak private var favoriteButton: UIButton!
    private var meal: Meal?
    var categoryName: String = ""
    
    func setup(meal: Meal) {
        self.meal = meal
        areaLabel.text = meal.area
        itemNameLabel.text = meal.name
        favoriteButton.isSelected = meal.favorite
        itemImageView.image = UIImage(named: "placeholder_recipe")
        if let mealImage = meal.image { itemImageView.image = mealImage }
        else {
            MealsManager.downloadImage(url: meal.imageURL) { (image) in
                if let mealImage = image {
                    DispatchQueue.main.async { self.itemImageView.image = mealImage }
                    meal.image = mealImage
                }
            }
        }
        if FavoritesManager.meals.filter({ $0.id == meal.id }).first != nil {
            favoriteButton.isSelected = true
            meal.favorite = true
        }
    }
    
    @IBAction func setFavoriteItem(_ sender: UIButton) {
        if let cellMeal = meal {
            meal?.favorite = !(meal?.favorite ?? true)
            sender.isSelected = !sender.isSelected
            FavoritesManager.saveMeal(cellMeal)
        }
    }
}
