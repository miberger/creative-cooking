//  creative Cooking Club
//

import UIKit

// This is the Meal/Recipe object that has meal name, instructions, image, etc
class Meal: NSObject {
    var id: String
    var name: String
    var imageURL: String
    var favorite: Bool = false
    var image: UIImage? = nil
    var area: String = ""
    var instructions: String = ""
    var ingredients: String = ""
    var videoInstruction: String = ""
    
    var mealDictionary: [String: Any] {
        var data: [String: Any] = [:]
        data["idMeal"] = id
        data["strMeal"] = name
        data["strMealThumb"] = imageURL
        data["strArea"] = area
        data["strInstructions"] = instructions
        data["strIngredients"] = ingredients
        data["strYoutube"] = videoInstruction
        return data
    }
    
    init?(dictionary: [String: Any]) {
        if let mealName = dictionary["strMeal"] as? String,
            let mealId = dictionary["idMeal"] as? String,
            let mealThumbnail = dictionary["strMealThumb"] as? String {
            self.id = mealId
            self.name = mealName
            self.imageURL = mealThumbnail
        } else { return nil }
    }
    
    /// Define meal details
    func setDetails(_ details: [String: Any]) {
        area = details["strArea"] as? String ?? ""
        instructions = details["strInstructions"] as? String ?? ""
        for index in 0..<details.count {
            if let ingredient = details["strIngredient\(index)"] as? String, !ingredient.isEmpty {
                let quantity = details["strMeasure\(index)"] as? String ?? ""
                self.ingredients.append("\(quantity) \(ingredient)\n")
            }
        }
    }
}
