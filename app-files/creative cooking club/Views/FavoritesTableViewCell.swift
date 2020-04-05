//  creative Cooking Club
//

import UIKit

// This is the cell/view that shows a favorite recipe in the list of Favorites
class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak private var recipeImageView: UIImageView!
    @IBOutlet weak private var recipeNameLabel: UILabel!
    @IBOutlet weak private var recipeAreaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        recipeImageView.layer.cornerRadius = 10
    }
    
    func configure(meal: Meal) {
        recipeAreaLabel.text = meal.area
        recipeNameLabel.text = meal.name
        recipeImageView.image = UIImage(named: "saved_recipe")
        if let mealImage = meal.image { recipeImageView.image = mealImage }
        else {
            MealsManager.downloadImage(url: meal.imageURL) { (image) in
                if let mealImage = image {
                    DispatchQueue.main.async { self.recipeImageView.image = mealImage }
                    meal.image = mealImage
                }
            }
        }
    }
}
