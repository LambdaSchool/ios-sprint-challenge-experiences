//
//  NewExperienceVC.swift
//  Experience
//
//  Created by Nikita Thomas on 1/18/19.
//  Copyright © 2019 Nikita Thomas. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class NewExperienceVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    
    var experienceCont: ExperienceController!
    
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    
    var imageURL: URL?
    var audioURL: URL?
    
    
    
    @IBAction func chosePhotoTapped(_ sender: Any) {
        showImagePicker()
    }
    
    
    @IBAction func recordTapped(_ sender: Any) {
        let isRecording = recorder?.isRecording ?? false
        
        // If already recording, stop the recording and return
        if isRecording {
            recorder?.stop()
            return
        }
        
        // Otherwise, start a new recording
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
            
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording")
        }
        updateViews()
    }
    
    @IBAction func playTapped(_ sender: Any) {
        let isPlaying = player?.isPlaying ?? false
        
        // If already playing, pause the playback and then return
        if isPlaying {
            player?.pause()
            return
        }
        
        // Past this point means we are playing a new URL
        
        guard let url = audioURL else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
        } catch {
            NSLog("Unable to start playing audio: \(error)")
        }
        updateViews()
    }
    
    
    
    func newRecordingURL() -> URL {
        
        let fileManager = FileManager.default
        let documentsDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // The UUID is the name of the file
        let newRecordingURL = documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
        
        return newRecordingURL
    }
    
    func updateViews() {
        let isPlaying = player?.isPlaying ?? false
        let playTitle = isPlaying ? "Pause" : "Play Recording"
        playButton.setTitle(playTitle, for: .normal)
        
        let isRecording = recorder?.isRecording ?? false
        let recordTitle = isRecording ? "Stop" : "Record Voice Memo"
        recordButton.setTitle(recordTitle, for: .normal)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    
    
    // MARK: Choosing Photo
    func showImagePicker() {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        choosePhotoButton.setTitle("", for: .normal)
        
        guard let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        
        do {
            self.imageURL = newImageURL()
            try chosenImage.jpegData(compressionQuality: 1.0)?.write(to: imageURL!)
            
        } catch {
            NSLog("Could not save image: \(error)")
        }
        
        imageView.image = chosenImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func newImageURL() -> URL {
        
        let fileManager = FileManager.default
        let documentsDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // The UUID is the name of the file
        let newRecordingURL = documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpeg")
        
        return newRecordingURL
    }
    
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideo" {
            let dest = segue.destination as! VideoVC
            
            dest.audioURL = audioURL
            dest.imageURL = imageURL
            dest.experienceCont = experienceCont
            dest.experienceTitle = titleTextField.text
        }
    }
 

}