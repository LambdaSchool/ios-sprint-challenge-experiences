
import UIKit

protocol AudioPostDelegate {
    func recordedFile(audio: URL)
}

class AudioAndPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PlayerDelegate, RecorderDelegate {
   
    
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func choosePhoto(_ sender: Any) {
        
        
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                print("The photo library is unavailable")
                return
            }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
            
        }
    private var originalImage: UIImage?
     let player = Player()
     let recorder = Recorder()
     var curentRecordedAudioURl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        recorder.delegate = self
    }

    @IBAction func tappedPlayButton(_ sender: Any) {
        // returns either the song if there is nothing recorded, or the most recent URL I have recorded
        player.playPause(song: recorder.currentFile)
    }
    
    @IBAction func tappedRecordButton(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    func playerDidChangeState(_ player: Player) {
        updateViews()
    }
    
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    // I want a single method to use to update everything at once
    private func updateViews() {
        let isPlaying = player.isPlaying
        playButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        let isRecording = recorder.isRecording
        recordButton.setTitle(isRecording ? "Stop" : "Record", for: .normal)
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Video" && textField.text != nil && imageView.image != nil{
            guard let destination = segue.destination as? CameraViewController else { return }
            destination.titleString = textField.text
            destination.image = imageView.image
            destination.curentRecordedAudioURL = recorder.currentFile
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        originalImage = info[.originalImage] as? UIImage
        imageView.image = originalImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
