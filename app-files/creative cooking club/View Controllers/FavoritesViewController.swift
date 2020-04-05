//  creative Cooking Club
//

import UIKit

// This is the favorites screen
class FavoritesViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var statusView: StatusView!
    
    /// Initial logic when screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Config.ScreenTitle.favorites
        displayStatusViewIfNeeded()
        FavoritesManager.didUpdateMeals = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.displayStatusViewIfNeeded()
            }
        }
    }
    
    /// Set the status bar color to default (black color)
    @available(iOS, deprecated: 9.0)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    /// Show the empty view if there are no favorite recipes (or hide the empty view)
    private func displayStatusViewIfNeeded() {
        statusView.configure(mode: .empty)
        statusView.isHidden = FavoritesManager.meals.count > 0
    }
}

// MARK: - Display all favorite meals/recipes in a list
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesManager.meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FavoritesTableViewCell {
            cell.configure(meal: FavoritesManager.meals[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meal = FavoritesManager.meals[indexPath.row]
        let details = storyboard?.instantiateViewController(withIdentifier: "details") as! DetailsViewController
        details.meal = meal
        navigationController?.pushViewController(details, animated: true)
    }
}
