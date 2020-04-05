//  creative Cooking Club
//

import UIKit

// This is the manager that handles all favorite meals/recipes
class FavoritesManager: NSObject {

    /// All favorite meals
    static var meals: [Meal] = []
    static var didUpdateMeals: (() -> Void)?
    static var didUpdateMealDetails: (() -> Void)?
    
    /// Save meal or Remove meal from favorites list
    static func saveMeal(_ meal: Meal) {
        let mealIds = FavoritesManager.meals.compactMap({ $0.id })
        if mealIds.contains(meal.id) == false {
            FavoritesManager.meals.append(meal)
        } else {
            FavoritesManager.meals.enumerated().forEach { (index, savedMeal) in
                if savedMeal.id  == meal.id { FavoritesManager.meals.remove(at: index) }
            }
        }
        var mealsDictionary: [String: Any] = [:]
        meals.forEach { (meal) in mealsDictionary[meal.id] = meal.mealDictionary }
        UserDefaults.standard.set(mealsDictionary, forKey: "meals")
        UserDefaults.standard.synchronize()
        FavoritesManager.didUpdateMeals?()
        FavoritesManager.didUpdateMealDetails?()
    }
    
    /// Get saved meals from UserDefaults
    static func restoreSavedMeals() {
        if let mealsData = UserDefaults.standard.dictionary(forKey: "meals") {
            mealsData.forEach { (mealId, mealDictionary) in
                if let dictionary = mealDictionary as? [String: Any],
                    let meal = Meal(dictionary: dictionary) {
                    meal.area = dictionary["strArea"] as? String ?? "N/A"
                    meal.instructions = dictionary["strInstructions"] as? String ?? "N/A"
                    meal.ingredients = dictionary["strIngredients"] as? String ?? "N/A"
                    FavoritesManager.meals.append(meal)
                }
            }
        }
    }
}
