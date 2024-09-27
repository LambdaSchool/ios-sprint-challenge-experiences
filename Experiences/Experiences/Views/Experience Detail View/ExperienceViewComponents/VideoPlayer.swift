//
//  VideoPlayer.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/17/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI
import AVKit

struct VideoPlayer: View {
    var videoURL: URL?
    
    var body: some View {
        VStack {
            MediaPlayer(mediaURL: videoURL)
        }
            .edgesIgnoringSafeArea(.vertical)
        .frame(width: screen.width, height: screen.height)
    }
}

struct VideoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE (2nd generation)", "iPhone 11", "iPhone 11 Pro Max"], id: \.self) { deviceName in
            VideoPlayer()
                .previewDevice(PreviewDevice(rawValue: deviceName))
        }
    }
}

struct MediaPlayer: UIViewControllerRepresentable {
    var mediaURL: URL?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MediaPlayer>) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
        
        if let mediaURL = mediaURL {
            let player = AVPlayer(url: mediaURL)
            controller.player = player
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<MediaPlayer>) {
        
    }
}
