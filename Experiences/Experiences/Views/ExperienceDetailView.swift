//
//  ExperienceDetailView.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit

class ExperienceDetailView: UIView {
    
    // MARK: - Properties
    let titleLabel = UILabel()
    let imageView = UIImageView()
    var experience: Experience? {
        didSet {
            updateSubviews()
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.setContentHuggingPriority(.defaultLow+1, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView])
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.axis = .vertical
        let mainStackView = UIStackView(arrangedSubviews: [stackView])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func updateSubviews() {
        guard let experience = experience else { return }
        titleLabel.text = experience.expTitle
        if let image = experience.image {
            imageView.image = image
        }
    }
}
