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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBAction Properties
    @IBAction func addImageButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func recordAudioButtonTapped(_ sender: Any) {
        updateButton()
    }
    
    @IBAction func playAudioRecordingButtonTapped(_ sender: Any) {
        updateButton()
    }
    
    @IBAction func addVideoButtonTapped(_ sender: Any) {
        
    }
}
