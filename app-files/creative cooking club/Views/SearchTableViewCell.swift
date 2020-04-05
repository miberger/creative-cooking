//  creative Cooking Club
//

import UIKit

// This shows the search result in Search screen
class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak private var recipeTitleLabel: UILabel!
    @IBOutlet weak private var recipeAreaLabel: UILabel!
    
    func configure(meal: Meal) {
        recipeTitleLabel.text = meal.name
        recipeAreaLabel.text = meal.area
    }
}
