//
//  ContactLabelTabelViewCell.swift
//  CoronaContact
//

import UIKit
import Reusable

class AutoMarginTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        var overridenMargin: CGFloat = 0
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.screenSize {
            case .small, .medium:
                overridenMargin = 16
            case .large:
                overridenMargin = 24
            }
        }
        self.layoutMargins = UIEdgeInsets(top: 0, left: overridenMargin, bottom: 0, right: overridenMargin)
    }
}
