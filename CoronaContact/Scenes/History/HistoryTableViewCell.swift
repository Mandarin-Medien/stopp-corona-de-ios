//
//  ContactTableViewCell.swift
//  CoronaContact
//

import UIKit

import Reusable

class HistoryTableViewCell: AutoMarginTableViewCell, NibReusable {
    @IBOutlet weak var dateLabel: TransLabel!
    @IBOutlet weak var timeLabel: TransLabel!
    let formatter = DateFormatter()

    func setUpCell(_ history: History) {
        dateLabel.styledText = history.dateString
        timeLabel.styledText = history.timeRangeString
    }

    override func awakeFromNib() {
        selectionStyle = .none
        formatter.dateStyle = .short
        super.awakeFromNib()
    }
}
