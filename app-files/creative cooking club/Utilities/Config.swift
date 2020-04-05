//  creative Cooking Club
//

import Foundation

// This is the main configuration file
// You can change text, URLs and more
class Config {
    
    /// These are the main URLs to get the recipes data
    static let mealsURL: String = "https://www.themealdb.com/api/json/v1/1/filter.php?c="
    static let mealDetailsURL: String = "https://www.themealdb.com/api/json/v1/1/lookup.php?i="
    static let searchMealsURL: String = "https://www.themealdb.com/api/json/v1/1/search.php?s="
    static let randomMealURL: String = "https://themealdb.com/api/json/v1/1/random.php"
    
    /// Here you can change the text for the status view
    static func getStatusViewDetails(mode: StatusMode) -> (title: String, message: String, icon: String) {
        switch mode {
        case .loading:
            return ("Give us a few seconds,", "We will help you make the best meal of the day.", "chef")
        case .error:
            return ("We're sorry", "Something went wrong.\nPlease try again later", "warning")
        case .empty:
            return ("So many choices!", "Like your favorite recipes and save them here for the future.", "chef")
        case .search:
            return ("No results", "It is time to be creative!", "chef")
        case .decide:
            return ("Feel lucky?", "Let us give you a surprise!", "chef")
        default: break
        }
        return ("Just think about ...", "your favorite dish.\nis on its way", "chef")
    }
    
    /// This is the struct with titles for each screen
    struct ScreenTitle {
        static let recipes = "CC Club Recipes"
        static let favorites = "CC Club Favorites"
        static let decide = "Feel Lucky"
        static let search = "CC Club Find"
    }
    
    /// how the detail screen will show the information
    struct DetailsSectionTitle {
        static let ingredients = "Ingredients"
        static let instructions = "Instructions"
    }
    
    /// Placeholder for integration with firebase. Change case to true. 
    static var shouldUseFirebase: Bool {
        switch MealsManager.currentCategory {
        case .Breakfast: return false
        default: break
        }
        return false
    }
}
