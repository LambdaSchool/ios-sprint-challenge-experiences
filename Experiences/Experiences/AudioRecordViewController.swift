//
//  AudioRecordViewController.swift
//  Experiences
//
//  Created by Karen Rodriguez on 5/8/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecordViewController: UIViewController {

    // MARK: - Properties

    var newExpController: NewExpViewController?

    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
        }
    }

    private var timer: Timer?

    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)

        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    var audioRecorder: AVAudioRecorder?

    var recordingURL: URL?

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

   // MARK: - Outlets
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!

    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: currentTimeLabel.font.pointSize, weight: .regular)
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: durationLabel.font.pointSize, weight: .regular)

        updateViews()
        try? prepareAudioSession()
    }

    deinit {
        cancelTimer()
    }
    // MARK: - Timer

    func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }

            self.updateViews()
        }
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Recording

    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        print("recording URL: \(file)")

        return file
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

    func startRecording() {
        let recordingURL = createNewRecordingURL()

        // Setup the AVAudioDrecorder and record

        // 44.1 KHz = FM radio quality
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: audioFormat) // FIXME: Error logic
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()

        self.recordingURL = recordingURL
    }

    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
    }

    // MARK: - Playback

    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }

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

    func updateViews() {
        playPauseButton.isSelected = isPlaying
        recordButton.isSelected = isRecording
        let elapsedTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0

        currentTimeLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        durationLabel.text = timeIntervalFormatter.string(from: duration)

        audioSlider.value = Float(elapsedTime)
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = Float(duration)
    }

    // MARK: - Actions

    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    @IBAction func updateCurrentTime(_ sender: UISlider) {
        if isPlaying {
            pause()
        }

        audioPlayer?.currentTime = TimeInterval(audioSlider.value)
        updateViews()
    }

    @IBAction func toggleRecording(_ sender: Any) {
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()
        }
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let recordingURL = recordingURL else { return }
        newExpController?.audioURL = recordingURL.path
        self.dismiss(animated: true, completion:    nil)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension AudioRecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Decode Error: \(error)")
        }
        updateViews()
    }
}

extension AudioRecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // play the recording
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
        }
        updateViews()
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder Error: \(error)")
        }
        updateViews()
    }
}
