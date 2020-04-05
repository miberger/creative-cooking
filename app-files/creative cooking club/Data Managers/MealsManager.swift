//  creative Cooking Club
//

import UIKit

// This represents all categories of food/recipes (at the top of the screen)
enum Category: String, CaseIterable {
    case Breakfast, Chicken, Beef, Lamb, Pork, Seafood, Side, Starter, Vegetarian, Vegan, Dessert
}

// This is the data manager that gets all food/recipes
class MealsManager {
    
    /// Meals for category
    static var meals: [Category: [Meal]] = [:]
    static var currentCategory: Category = .Breakfast
    
    /// Get meals based on 'currentCategory' and return success or failure response
    static func getMeals(completion: @escaping (_ success: Bool) -> Void) {
        let category = MealsManager.currentCategory
        MealsManager.mealIndex = 0
        if MealsManager.meals[category]?.count ?? 0 > 0 { completion(true); return }
        if Config.shouldUseFirebase { FirebaseManager.shared.getMeals(completion: completion); return }
        let requestURL = URL(string: "\(Config.mealsURL)\(category.rawValue)")!
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            guard let requestData = data else { completion(false); return }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: requestData, options: []) as? [String: Any]
                if let mealObjects = jsonResponse?["meals"] as? [[String: Any]] {
                    mealObjects.forEach { (mealData) in
                        MealsManager.add(mealData: mealData, category: category)
                    }
                    MealsManager.getMealDetails(completion: completion)
                } else { completion(false) }
            } catch { completion(false) }
        }.resume()
    }
    
    /// Add meal/recipe object to the array
    static func add(mealData: [String: Any]?, category: Category) {
        if let mealDictionary = mealData, let meal = Meal(dictionary: mealDictionary) {
            if MealsManager.meals[category] == nil {
                MealsManager.meals[category] = []
                MealsManager.meals[category]?.append(meal)
            } else { MealsManager.meals[category]?.append(meal) }
        }
    }
    
    /// Get details for each meal/recipe
    static var mealIndex: Int = 0
    static func getMealDetails(completion: @escaping (_ success: Bool) -> Void) {
        if let meals = MealsManager.meals[MealsManager.currentCategory], meals.count > mealIndex {
            let id = meals[mealIndex].id
            let requestURL = URL(string: "\(Config.mealDetailsURL)\(id)")!
            URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
                guard let requestData = data else { completion(false); return }
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: requestData, options: []) as? [String: Any]
                    if let mealObject = (jsonResponse?["meals"] as? [[String: Any]])?.first {
                        MealsManager.meals[MealsManager.currentCategory]![mealIndex].setDetails(mealObject)
                        MealsManager.mealIndex += 1
                        MealsManager.getMealDetails(completion: completion)
                    } else { completion(false) }
                } catch { completion(false) }
            }.resume()
        } else { completion(true) }
    }
    
    /// Download image for a given url
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let url = URL(string: url)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, let img = UIImage(data: data) else { completion(nil); return }
            completion(img)
        }.resume()
    }
}
