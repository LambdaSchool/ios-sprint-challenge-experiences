//
//  ReviewViewController.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/27/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import AVKit
import AVFoundation
import MapKit


class ReviewViewController: UIViewController {
    
    //Properties
    static var previewVideo: URL?
    
    private var player: AVPlayer?
    
    private let playerController = AVPlayerViewController()
    
    private let cdc = CoreDataController.shared
    
    var vidEntryTitle: String?
    var vidEntryPhoto: URL?
    var vidEntryLocation: CLLocationCoordinate2D?
    
    //Outlets
    @IBOutlet weak var vidScreen: UIView!
    
    @IBOutlet weak var entryTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
        playerController.player = player
        playerController.view.frame = vidScreen.bounds
        self.addChild(playerController) //Lets another VC work in this one
        vidScreen.addSubview(playerController.view)//Shows vid player in view
        playerController.didMove(toParent: self)
        playerController.showsPlaybackControls = false
        seeVideo()
    }
    
    func seeVideo(){
        //Check if there's already a player
        
        playerController.player = try! AVPlayer(url: ReviewViewController.previewVideo!)
        
        //Play the file
        playerController.player?.play()
        
        //updateButtons() //When the user pauses the song
    }//End of function
    
    
    @IBAction func saveVidClicked(_ sender: Any) {
        
        let currentDate = Date()
        
        cdc.newEntry(entryTitle: vidEntryTitle!, entryPhoto: vidEntryPhoto!, entryVid: ReviewViewController.previewVideo, entryDate: currentDate, entryLocation: vidEntryLocation)
    }
    
}


