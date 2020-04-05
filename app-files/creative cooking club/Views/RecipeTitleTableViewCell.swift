//  creative Cooking Club
//

import UIKit

/// Base class for all meal details sections/cells
class MealDetailsTableViewCell: UITableViewCell {
    func configure(meal: Meal) { }
}

// This shows the recipe title and recipe area in Details screen
class RecipeTitleTableViewCell: MealDetailsTableViewCell {

    @IBOutlet weak private var recipeTitleLabel: UILabel!
    @IBOutlet weak private var recipeAreaLabel: UILabel!
    
    override func configure(meal: Meal) {
        recipeTitleLabel.text = meal.name
        recipeAreaLabel.text = meal.area
    }
}
