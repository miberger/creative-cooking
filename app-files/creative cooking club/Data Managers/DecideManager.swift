//  creative Cooking Club
//

import UIKit

// This manager will get a random recipe
class DecideManager: NSObject {

    /// Get a random meal/recipe
    static func getRandomMeal(completion: @escaping (_ meal: Meal?) -> Void) {
        let requestURL = URL(string: "\(Config.randomMealURL)")!
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            guard let requestData = data else { completion(nil); return }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: requestData, options: []) as? [String: Any]
                if let mealDictionary = (jsonResponse?["meals"] as? [[String: Any]])?.first {
                    if let randomMeal = Meal(dictionary: mealDictionary) {
                        randomMeal.setDetails(mealDictionary)
                        DecideManager.downloadImage(url: randomMeal.imageURL) { (image) in
                            if let mealImage = image {
                                randomMeal.image = mealImage
                                completion(randomMeal)
                            } else { completion(nil) }
                        }
                    } else { completion(nil) }
                } else { completion(nil) }
            } catch { completion(nil) }
        }.resume()
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
