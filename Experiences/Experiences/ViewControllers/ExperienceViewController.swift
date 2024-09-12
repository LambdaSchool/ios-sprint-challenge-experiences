//
//  ExperienceViewController.swift
//  Experiences
//
//  Created by Hayden Hastings on 7/12/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ExperienceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
    
    // MARK: - IBOutlets Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var playAudioButton: UIButton!
    
    // MARK: - Properties
    var filteredImage: UIImage?
    private let filterEffect = CIFilter(name: "CIPhotoEffectTonal")
    private let context = CIContext(options: nil)
    
    private var player: AVAudioPlayer?
    
    var originalImage: UIImage? {
        didSet {
            updateImageViews()
        }
    }
    
    var recordingURL: URL?
    private var recorder: AVAudioRecorder?
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    private var audioPlayer: AVAudioPlayer?
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer?.delegate = self
        recorder?.delegate = self
        titleTextField.delegate = self
    }
    
    // MARK: - Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updateImageViews() {
        guard let image = originalImage else { return }
        imageView.image = applyImageFilter(to: image)
        filteredImage = applyImageFilter(to: image)
    }
    
    private func applyImageFilter(to image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        filterEffect?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputImage = filterEffect?.outputImage,
            let cgImages = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        return UIImage(cgImage: cgImages)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        originalImage = info[.originalImage] as? UIImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func newRecordingURL() -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    private func updateButton() {
        let playAudioTitle = isPlaying ? "Stop Playing" : "Play"
        playAudioButton.setTitle(playAudioTitle, for: .normal)
        
        let recordAudioTitle = isRecording ? "Stop Recording" : "Record"
        recordAudioButton.setTitle(recordAudioTitle, for: .normal)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateButton()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        updateButton()
        recordingURL = recorder.url
    }
    
    func saveImage(image: UIImage) -> URL {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError("No access to documents directory at this time.") }
        
        let fileURL = documentDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpeg")
        guard let data = image.jpegData(compressionQuality: 0.8) else { fatalError("No data returned") }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                NSLog("Could not delete the file at path: \(fileURL.path)")
            }
        }
        do {
            try data.write(to: fileURL)
        } catch {
            NSLog("There was an error while trying to save/write to file.")
        }
        return fileURL
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideoVC" {
            let destinationVC = segue.destination as? VideoRecordingViewController
            guard let image = imageView.image,
                let audioURL = recordingURL else { return }
            
            destinationVC?.audioURL = audioURL
            destinationVC?.imageURL = saveImage(image: image)
            destinationVC?.titleTextString = titleTextField.text
        }
    }
    
    // MARK: - IBAction Properties
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            
            let alert = UIAlertController(title: "Error", message: "Could not reach photo library at this time", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
            
            return
        }
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func recordAudioButtonTapped(_ sender: UIButton) {
        if isRecording {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.record()
            recorder?.delegate = self
        } catch {
            NSLog("Unable to start recording: \(error)")
        }
        updateButton()
    }
    
    @IBAction func playAudioRecordingButtonTapped(_ sender: UIButton) {
        guard let recordingURL = recordingURL else {return}
        
        if isPlaying {
            player?.stop()
            return
        }
        
        do {
            //Set up the player with the sample audio file
            player = try AVAudioPlayer(contentsOf: recordingURL)
            
            player?.play()
            
            //the VC adding itself as the observer of the delegate method.
            player?.delegate = self
        } catch {
            NSLog("Error attmepting to start playing audio: \(error)")
        }
        updateButton()
    }
    
    @IBAction func addVideoButtonTapped(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty, (recordingURL != nil) else {
            
            let alert = UIAlertController(title: "Error", message: "Please make sure you have both a title text and an audio recording!", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(alertAction)
            
            present(alert, animated: true, completion: nil)
            return
            
        }
        performSegue(withIdentifier: "toVideoVC", sender: self)
    }
}
