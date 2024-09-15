//
//  EntryView.swift
//  Experiences
//
//  Created by Alex Shillingford on 2/24/20.
//  Copyright © 2020 shillwil. All rights reserved.
//
import Foundation
import UIKit

protocol ViewButtonTapped {
    func viewButtonWasTapped(sender: Any?)
}


class EntryView: UIView {

    // MARK: - Properties
    var entry: ExperienceEntry? {
        didSet {
            updateSubviews()
        }
    }
    
    var delegate: ViewButtonTapped?
    
    private let nameLabel = UILabel()
    private let viewButton = UIButton()
    
    private lazy var dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        result.timeStyle = .short
        return result
    }()
    
    private lazy var latLonFormatter: NumberFormatter = {
        let result = NumberFormatter()
        result.numberStyle = .decimal
        result.minimumIntegerDigits = 1
        result.minimumFractionDigits = 2
        result.maximumFractionDigits = 2
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nameLabel.setContentHuggingPriority(.defaultLow+1, for: .horizontal)
        
        let latLonStackView = UIStackView(arrangedSubviews: [nameLabel, viewButton])
        latLonStackView.spacing = UIStackView.spacingUseSystem
        let mainStackView = UIStackView(arrangedSubviews: [latLonStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = UIStackView.spacingUseSystem
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        mainStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    @objc func viewButtonTapped() {
        delegate?.viewButtonWasTapped(sender: viewButton)
    }
    
    // MARK: - Private
    
    private func updateSubviews() {
        guard let entry = entry else { return }
        nameLabel.text = entry.title
        viewButton.titleLabel?.text = "View"
        viewButton.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
    }

}
