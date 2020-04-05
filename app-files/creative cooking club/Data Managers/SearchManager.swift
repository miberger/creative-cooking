//  creative Cooking Club
//

import UIKit

// This is the search manager that will search recipes based on entered text
class SearchManager: NSObject {

    /// Holds all meals from the service response
    static var foundMeals: [Meal] = []
    
    /// Search for meals/recipes based on search text
    static func search(term: String?, completion: @escaping ((_ meals: [Meal]?) -> Void)) {
        guard let text = term, !text.isEmpty else { completion(nil); return }
        foundMeals.removeAll()
        let requestURL = URL(string: "\(Config.searchMealsURL)\(text.replacingOccurrences(of: " ", with: ""))")!
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            guard let requestData = data else { completion(nil); return }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: requestData, options: []) as? [String: Any]
                if let mealObjects = jsonResponse?["meals"] as? [[String: Any]] {
                    mealObjects.forEach { (mealData) in SearchManager.add(mealData: mealData) }
                    completion(foundMeals)
                } else { completion(nil) }
            } catch { completion(nil) }
        }.resume()
    }
    
    /// Add meal/recipe details to the array of found meals
    static func add(mealData: [String: Any]?) {
        if let mealDictionary = mealData, let meal = Meal(dictionary: mealDictionary) {
            let mealIds = SearchManager.foundMeals.compactMap({ $0.id })
            if mealIds.contains(meal.id) == false {
                meal.setDetails(mealDictionary)
                SearchManager.foundMeals.append(meal)
            }
        }
    }
}
