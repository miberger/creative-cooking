//  creative Cooking Club
//

import UIKit

// This shows the instructions in Details screen
class InstructionsTableViewCell: MealDetailsTableViewCell {

    @IBOutlet weak private var instructionsLabel: UILabel!
    @IBOutlet weak private var instructionsTitle: UILabel!
    
    override func configure(meal: Meal) {
        instructionsLabel.text = meal.instructions
        instructionsTitle.text = Config.DetailsSectionTitle.instructions
    }

}
