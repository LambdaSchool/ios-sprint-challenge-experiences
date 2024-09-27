//
//  PostViewController.swift
//  Experiences
//
//  Created by Ufuk Türközü on 10.04.20.
//  Copyright © 2020 Ufuk Türközü. All rights reserved.
//

import UIKit
import UIKit.UIKitCore
import AVFoundation
import MapKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK: - Image Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    // MARK: - Audio Outlets
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet weak var titleTF: UITextField!
    
    // MARK: - Properties
    var coordinates: CLLocationCoordinate2D?
    var image: UIImage?
    var audio: URL?
    var video: URL?
    
    var experienceController: ExperienceController?
    
    // MARK: - Image Properties
    let imagePC = UIImagePickerController()
    private let context = CIContext(options: nil)
    
    // MARK: - Audio Properties
    private var timer: Timer?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
        }
    }
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false // single line method, you can omit the return
    }
    
    var audioRecorder: AVAudioRecorder? {
        didSet {
            audioRecorder?.isMeteringEnabled = true
        }
    }
    
    var recordingURL: URL?
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    // TIMER
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // TITLE
        titleTF.delegate = self
        // IMAGE
        imagePC.delegate = self
        // AUDIO
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                                 weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
    }
    
    @IBAction func Save(_ sender: Any) {
        guard let coordinates = coordinates else { return }
        experienceController?.createExperience(title: titleTF.text ?? "", coordinate: coordinates, video: video, audio: audio, image: image)
        navigationController?.popViewController(animated: true)
        print("Title: \(experienceController?.experiences.last?.title)")
        print("Coordinates: \(experienceController?.experiences.last?.coordinate)")
        print("Image: \(experienceController?.experiences.last?.image)")
        print("Audio: \(experienceController?.experiences.last?.audio)")
        print("Video: \(experienceController?.experiences.last?.video)")
    }
    
    func updateViews() {
        playButton.isSelected = isPlaying
        recordButton.isSelected = isRecording
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        let remainingTime = duration - elapsedTime
        timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        timeRemainingLabel.text = timeIntervalFormatter.string(from: remainingTime)
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(elapsedTime)
    }
    
    // MARK: - Audio Actions
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    @IBAction func toggleRecording(_ sender: Any) {
        
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()
        }
    }
    
    @IBAction func updateCurrentTime(_ sender: Any) {
        if isPlaying {
            pause()
        }
        audioPlayer?.currentTime = TimeInterval(timeSlider.value)
        updateViews()
    }
    
    // MARK: - Image Actions
    @IBAction func addImage(_ sender: Any) {
        imagePC.allowsEditing = true
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default , handler: { (sction: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePC.sourceType = .camera
                self.present(self.imagePC, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Libary", style: .default , handler: { (sction: UIAlertAction) in
            self.imagePC.sourceType = .photoLibrary
            self.present(self.imagePC, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true)
    }
    
    func filterImage(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage (CoreGrephics) -> CIImage (CoreImage)
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        // Filter
        let filter = CIFilter.dotScreen()
        filter.inputImage = ciImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage,
        from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        // CIImage -> CGImage -> UIImage
        return UIImage(cgImage: outputCGImage)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let editedImage = filterImage(image)
        
        DispatchQueue.main.async {
            NSLog("Experience Image: \(String(describing: editedImage))")
            self.imageView.image = editedImage
            self.image = editedImage
            self.imageButton.isHidden = true
            self.dismiss(animated: true, completion: nil)
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordVideoSegue" {
            let destinationVC = segue.destination as? VideoPostViewController
            //destinationVC?.experienceController = experienceController
            destinationVC?.delegate = self
        }
     }
}

// MARK: - Audio Extension
extension PostViewController {
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    
    // MARK: - Timer
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {
                audioPlayer.updateMeters()
            }
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Recorder
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false)

        return file
    }
    
    func startRecording() {
        let recordingURL = createNewRecordingURL().appendingPathExtension("caf")
        self.recordingURL = recordingURL
        // Setup the AVAudioRecorder and record
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: audioFormat) // FIXME: error logic
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
        
    }
    
    func stopRecording() {
        audioRecorder?.stop()
    }
    
    // MARK: - Playback
    func play() {
        audioPlayer?.play()
        startTimer()
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        cancelTimer()
        updateViews()
    }
}

extension PostViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        if let error = error {
            NSLog("Audio Player Decode Error: \(error)")
        }
        updateViews()
    }
}

extension PostViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // Setup the player to play the recording
        if let recordingURL = recordingURL {
            self.audio = recordingURL
            NSLog("Experience Audio: \(String(describing: audio))")
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
            //FIXME: do/catch
        }
        updateViews()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        if let error = error {
            NSLog("Audio Recorder Error: \(error)")
        }
        updateViews()
    }
}

extension PostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension PostViewController: VideoPostViewControllerDelegate {
    func videoURL(_ url: URL) {
        video = url
    }
}
