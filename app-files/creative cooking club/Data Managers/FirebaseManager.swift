//  creative Cooking Club
//


import UIKit
import Firebase

// This is the manager to get data from Firebase
class FirebaseManager: NSObject {

    /// Singleton pattern is being used here
    static var shared = FirebaseManager()
    private var database = Database.database().reference()
    
    /// Get meals based on 'currentCategory' and return success or failure response
    func getMeals(completion: @escaping (_ success: Bool) -> Void) {
        let category = MealsManager.currentCategory.rawValue
        database.child(category).observeSingleEvent(of: .value) { (snapshot) in
            if let meals = (snapshot.value as? [String: Any])?["meals"] as? [[String: Any]] {
                meals.forEach { (mealData) in
                    MealsManager.add(mealData: mealData, category: MealsManager.currentCategory)
                }
                FirebaseManager.shared.getMealDetails(completion: completion)
            } else { completion(false) }
        }
    }
    
    /// Get details for each meal/recipe
    func getMealDetails(completion: @escaping (_ success: Bool) -> Void) {
        if let meals = MealsManager.meals[MealsManager.currentCategory], meals.count > MealsManager.mealIndex {
            let id = meals[MealsManager.mealIndex].id
            database.child(id).observeSingleEvent(of: .value) { (snapshot) in
                if let meal = ((snapshot.value as? [String: Any])?["meals"] as? [[String: Any]])?.first {
                    MealsManager.meals[MealsManager.currentCategory]![MealsManager.mealIndex].setDetails(meal)
                    MealsManager.mealIndex += 1
                    self.getMealDetails(completion: completion)
                } else { completion(false) }
            }
        } else { completion(true) }
    }
}
