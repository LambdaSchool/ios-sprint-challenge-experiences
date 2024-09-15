//
//  AddMediaPostViewController.swift
//  Experiences
//
//  Created by Alex Shillingford on 2/14/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import UIKit
import CoreImage
import Photos
import AVFoundation

class AddMediaPostViewController: UIViewController {
    
    // MARK: - Properties
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var timer: Timer?
    var recordingSession = AVAudioSession.sharedInstance()
    
    static var experiences: [ExperienceEntry] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mediaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(AVAudioSession.sharedInstance().recordPermission.rawValue)")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tapGesture:)))
        imageView.addGestureRecognizer(tapGesture)
        //        replayButton.isHidden = true
    }
    
    // MARK: - Photo Helper Methods
    private func showImagePicker() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    //MARK: - Audio Helper Methods
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer) {
        
        print("tap")
        
        switch tapGesture.state {
        case .ended: // finished tapping the screen
            playPause()
        default:
            print("Handle other states: \(tapGesture.state)")
        }
        
    }
    
    func loadAudio() {
        // app bundle is read-only folder
        //        let songURL = Bundle.main.url(forResource: recordingURL?.absoluteString, withExtension: "caf")! // Programmer error if this fails to load
        guard let songURL = recordingURL else { return }
        
        audioPlayer = try? AVAudioPlayer(contentsOf: songURL) // FIX_ME: use better error handling
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.delegate = self
    }
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    func startRecording() {
        recordingURL = makeNewRecordingURL()
        if let recordingURL = recordingURL {
            print("URL: \(recordingURL)")
            
            // 44.1 KHz = FM quality audio
            let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)! // FIX_ME: can fail
            audioRecorder = try! AVAudioRecorder(url: recordingURL, format: format) // FIXME: Deal with errors fatalError()
            audioRecorder?.record()
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
        }
    }
    
    func requestRecordPermission() {
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    guard granted == true else {
                        fatalError("We need microphone access")
                    }
                    self.startRecording()
                }
            }
        } catch {
            fatalError("Something went wrong setting up recording session: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        replayButton.isHidden = false
        loadAudio()
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            requestRecordPermission()
        }
    }
    
    func makeNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // 2020-01-18T23/10/40-08/00.caf
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let url = documents.appendingPathComponent(name).appendingPathExtension("caf")
        recordingURL = url
        return url
    }
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func play() {
        audioPlayer?.play()
        
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func chooseMediaSegmentedControl(_ sender: UISegmentedControl) {
        switch mediaSegmentedControl.selectedSegmentIndex {
        case 0:
            addButton.backgroundColor = .blue
        case 1:
            addButton.backgroundColor = .green
            self.performSegue(withIdentifier: "CameraSegue", sender: sender)
        case 2:
            addButton.backgroundColor = .purple
            if isRecording {
                addButton.titleLabel?.text = "Stop"
            } else {
                addButton.titleLabel?.text = "Start"
            }
        default:
            print("default")
        }
    }
    
    
    @IBAction func cancelPost(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func post(_ sender: UIButton) {
        switch mediaSegmentedControl.selectedSegmentIndex {
        case 0:
            if let title = titleTextField.text,
                !title.isEmpty,
                let description = descriptionTextView.text,
                let image = imageView.image {
                let entry = ExperienceEntry(title: title, description: description, photo: image, movie: nil, audio: nil, id: UUID(), geotag: ViewController.shared.userLoc)
                AddMediaPostViewController.experiences.append(entry)
                print(AddMediaPostViewController.experiences.description)
                self.dismiss(animated: true)
            }
        case 1:
            do {
                if let title = titleTextField.text,
                    !title.isEmpty,
                    let description = descriptionTextView.text,
                    let audioURL = recordingURL {
                    let audioFile = try AVAudioFile(forReading: audioURL)
                    let entry = ExperienceEntry(title: title, description: description, photo: nil, movie: nil, audio: audioFile, id: UUID(), geotag: ViewController.shared.userLoc)
                    AddMediaPostViewController.experiences.append(entry)
                    print(AddMediaPostViewController.experiences.description)
                    self.dismiss(animated: true)
                }
            } catch {
                fatalError("Couldn't create post")
            }
        case 2:
            print("recording")
        default:
            print("default")
        }
        
        
    }
    
    @IBAction func addMediaButtonTapped(_ sender: UIButton) {
        switch mediaSegmentedControl.selectedSegmentIndex {
        case 0:
            showImagePicker()
        case 1:
            print(1)
        case 2:
            toggleRecording()
            replayButton.isHidden = false
        default:
            print("unknown default")
        }
    }
    
    @IBAction func replay(_ sender: UIButton) {
        playPause()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - Extensions
extension AddMediaPostViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension AddMediaPostViewController: UINavigationControllerDelegate {
    
}

extension AddMediaPostViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("AudioPlayer Error: \(error)")
        }
    }
    
}

extension AddMediaPostViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag == true {
            // update player to load the new file
            if let recordingURL = recordingURL {
                audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
                audioPlayer?.isMeteringEnabled = true
            }
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("AudioRecorder error: \(error)")
        }
    }
}
