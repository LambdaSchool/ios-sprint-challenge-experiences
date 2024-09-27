//
//  VideoPlayerView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/23/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import UIKit
import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {
    var experience: Experience
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero, experience: experience)
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    var experience: Experience?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(frame: CGRect, experience: Experience) {
        self.init(frame: frame)
        self.experience = experience
        guard let url = experience.videoURL else { return }
        let player = AVPlayer(url: url)
        player.play()
        
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
