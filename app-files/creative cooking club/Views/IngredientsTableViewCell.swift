//  creative Cooking Club
//

import UIKit

// This shows the ingredients in Details screen
class IngredientsTableViewCell: MealDetailsTableViewCell {

    @IBOutlet weak private var ingredientsLabel: UILabel!
    @IBOutlet weak private var ingredientsTitle: UILabel!
    
    override func configure(meal: Meal) {
        ingredientsLabel.text = meal.ingredients
        ingredientsTitle.text = Config.DetailsSectionTitle.ingredients
    }
}
