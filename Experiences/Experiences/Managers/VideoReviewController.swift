//
//  VideoReviewController.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/23/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//
/*
import UIKit
import AVFoundation
import AVKit

class VideoReviewController: UIViewController {
    
    var player = AVPlayer()
    var playerViewController = AVPlayerViewController()

    
    
    func playVideo() {
        
        let videoPath = Bundle.main.path(forResource: selectedVideo.videoFileName, ofType: "mp4")
        
        let videoPathURL = URL(fileURLWithPath: videoPath!)
        
        player = AVPlayer(url: videoPathURL)
        playerViewController.player = player
        
        self.present(playerViewController, animated: true, completion: nil)
        
        //Can also do completion: { self.playerViewController.player?.play() }
        
    }
    
    
    
    //Options for Video
    guard let mediaType = info[UIImagePickerController.InfoKey.mediaURL] as? String else { return }
    
    //Make sure the video is the correct format.
    guard mediaType == (kUTTypeMovie as String) else { return }
    
    //Unwrap url of the recorded video.
    guard let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
    
    //Checks if the video can be saved to the User's Camera Roll.
    guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) else { return }
    
    print(url.path)
    
}
*/
