//  creative Cooking Club
//

import UIKit
import Firebase

// This is the search screen where user can search for meals
class SearchViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    // this will come from the Firebase list
    
    // MARK: Properties
    var items: [GroceryItem] = []
    var user: User!
    let ref = Database.database().reference(withPath: "grocery-items")
    let usersRef = Database.database().reference(withPath: "online")
    
    var searchList = ""
   
    
    @IBOutlet weak private var statusView: StatusView!
    @IBOutlet weak private var tableView: UITableView!
    private var didSelectSearchButton: Bool = false
    private var results: [Meal] = []
    
    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Config.ScreenTitle.search
        statusView.configure(mode: .search)
        setupSearchBar()
        
        
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
          var newItems: [GroceryItem] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let groceryItem = GroceryItem(snapshot: snapshot) {
              newItems.append(groceryItem)
            }
          }
            self.items = newItems

/// how to use substring and index
/// newItems.description.index(newItems.description.startIndex, offsetBy: 118)..<newItems.description.endIndex
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            label.center = CGPoint(x: 160, y: 285)
            label.textAlignment = .center
            
//            let new_text = newItems.description
//            let r = newItems.description.index(newItems.description.firstIndex(of: "\"")!, offsetBy: 1)..<newItems.description.endIndex
//            let r_2 = new_text.substring(with: r).index(new_text.substring(with: r).startIndex, offsetBy:0)..<new_text.substring(with: r).firstIndex(of: "\"")!
//            let help_text = new_text.substring(with: r).substring(with: r_2)
//            label.text = help_text.replacingOccurrences(of: " ", with: "")
//            self.view.addSubview(label)

            if newItems.description.count > 50 {
            let new_text = newItems.description
            let r = newItems.description.index(newItems.description.firstIndex(of: "\"")!, offsetBy: 1)..<newItems.description.endIndex
            let r_2 = new_text.substring(with: r).index(new_text.substring(with: r).startIndex, offsetBy:0)..<new_text.substring(with: r).firstIndex(of: "\"")!
            let help_text = new_text.substring(with: r).substring(with: r_2)
                self.searchList = help_text.replacingOccurrences(of: " ", with: "")

                SearchManager.search(term: self.searchList) { (meals) in
                self.results = meals ?? []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.statusView.isHidden = self.results.count > 0
                }
                }
                
            }
            else {
                
                  let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                  label.center = CGPoint(x: 160, y: 285)
                  label.textAlignment = .center
                  label.text = "No ingredient"
                  self.view.addSubview(label)}
        })
    
        Auth.auth().addStateDidChangeListener { auth, user in
          guard let user = user else { return }
          self.user = User(authData: user)
          
          let currentUserRef = self.usersRef.child(self.user.uid)
          currentUserRef.setValue(self.user.email)
          currentUserRef.onDisconnectRemoveValue()
        }
        
//        SearchManager.search(term: searchList) { (meals) in
//            self.results = meals ?? []
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.statusView.isHidden = self.results.count > 0
//            }
//        }
    }
    
    /// Set the status bar color to default (black color)
    @available(iOS, deprecated: 9.0)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    /// get the lable value from viewController
    var searchLabel = ViewController()
    /// label value will be searchLabel.resultsText

    
    /// Dismiss search bar when user taps anywhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationItem.searchController?.isActive = false
    }
    
    /// Setup the search bar
    private func setupSearchBar() {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Search for recipes"
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        search.searchBar.tintColor = .black
        search.searchBar.showsCancelButton = false
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
    }
    

        
    
    /// Handle search bar type input and perform recipes search
    func updateSearchResults(for searchController: UISearchController) {
        if didSelectSearchButton { return }
        let text = searchController.searchBar.text
        SearchManager.search(term: text) { (meals) in
            self.results = meals ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.statusView.isHidden = self.results.count > 0
            }
        }
    }
    
    /// When user finished typing, dismiss the search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        didSelectSearchButton = true
        navigationItem.searchController?.isActive = false
    }
    
    /// When user started typing, reset the results and show empty view if needed
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.results.removeAll()
            self.tableView.reloadData()
            self.statusView.isHidden = self.results.count > 0
        }
    }
}

// MARK: - Display all search results if any
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? SearchTableViewCell {
            cell.configure(meal: results[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = storyboard?.instantiateViewController(withIdentifier: "details") as! DetailsViewController
        details.meal = results[indexPath.row]
        navigationController?.pushViewController(details, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 20 && navigationItem.searchController?.isActive ?? false {
            navigationItem.searchController?.isActive = false
        }
    }
}

