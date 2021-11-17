//
//  ButtonsTableViewCell.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 11.06.21.
//

import UIKit

class ButtonsTableViewCell: UITableViewCell {

    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    private let formatter = DateComponentsFormatter()
    weak var delegate: MovieDetailsViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        playButton.layer.cornerRadius = 5
        watchedButton.layer.cornerRadius = 5
        rateButton.layer.cornerRadius = 5
    }

    func configureWith(metadata: Metadata) {
        if let year = metadata.year {
            yearLabel.text = "\(year)"
        }
        summaryLabel.text = metadata.summary
        if let duration = metadata.duration {
            durationLabel.text = formatter.string(from: TimeInterval(duration / 1000))
        }
    }

    @IBAction func playButton(_ sender: Any) {
        delegate?.playerButtonPressed()
    }

}
