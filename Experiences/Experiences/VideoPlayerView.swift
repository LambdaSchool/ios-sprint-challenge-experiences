//
//  VideoPlayerView.swift
//  VideoPosts
//
//  Created by Tobi Kuyoro on 06/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var videoPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    var player: AVPlayer? {
        get { return videoPlayerLayer.player }
        set { videoPlayerLayer.player = newValue }
    }
}
