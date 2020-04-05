//  creative Cooking Club
//

import UIKit

// This is the view that shows a category in the scroll view at the top of the screen
class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var categoryImageView: UIImageView!
    @IBOutlet weak private var categoryLabel: UILabel!
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 12
    var categoryName: String = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if  shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 5, y: 5, width: bounds.width - 10, height: bounds.height - 10), cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.yellow.cgColor
            shadowLayer.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = .zero
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 9
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    func setSelected(_ selected: Bool) {
        shadowLayer?.fillColor = selected ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor : UIColor.white.cgColor
        categoryLabel.textColor = selected ? .white : .lightGray
    }
    
    func setCategory(name: String) {
        categoryLabel.text = name
        categoryImageView.image = UIImage(named: name)
    }
}
