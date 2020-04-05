//  creative Cooking Club
//

import UIKit

// Status view modes
enum StatusMode {
    case loading, error, success, empty, search, decide
}

// status view details
class StatusView: UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak private var statusImageView: UIImageView!
    @IBOutlet weak private var statusTitleLabel: UILabel!
    @IBOutlet weak private var statusMessageLabel: UILabel!
    var mode: StatusMode = .loading
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed("StatusView", owner: self, options: [:])
        addModalSubview(containerView)
    }
    
    func configure(mode: StatusMode) {
        let details = Config.getStatusViewDetails(mode: mode)
        statusImageView.image = UIImage(named: details.icon)
        statusTitleLabel.text = details.title
        statusMessageLabel.text = details.message
    }
}
