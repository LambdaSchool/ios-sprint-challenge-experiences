//
//  AddExperienceView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/17/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI
import MapKit

enum ActiveSheet {
   case photo, audio, video, location
}

struct AddExperienceView: View {
    @EnvironmentObject var data: ExperienceData
    @EnvironmentObject var locationData: LocationData
    @Environment(\.presentationMode) var presentationMode
    
    @State var experienceTitleText: String = ""
    
    @State var showingSheet = false
    @State var activeSheet: ActiveSheet = .photo
    
    @State var image: UIImage?
    @State var inputImage: UIImage?
    @State var showingImagePicker = false
    
    @State var audioURL: URL?
    @State var showingAudioRecorder = false
    
    @State var videoURL: URL?
    
    @State var latitude: Double
    @State var longitude: Double
    
    var body: some View {
        VStack {
            TextField("Enter a title...", text: $experienceTitleText)
                .frame(height: 30)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)), lineWidth: 1).shadow(color: .black, radius: 3, x: 0, y: 3))
                .padding(8)
            
            
            
            ScrollView {
                AddPhotoCellView()
                    .onTapGesture {
                        self.showingSheet.toggle()
                        self.activeSheet = .photo
                    }
                
                AddAudioCellView()
                    .onTapGesture {
                        self.showingSheet.toggle()
                        self.activeSheet = .audio
                    }
                
                AddVideoCellView()
                    .onTapGesture {
                        self.showingSheet.toggle()
                        self.activeSheet = .video
                    }
                
                AddLocationCellView()
                    .onTapGesture {
                        self.showingSheet.toggle()
                        self.activeSheet = .location
                    }
            }
            Spacer()
            
            Button(action: self.post) {
                DoneButtonView()
            }
        }
        .sheet(isPresented: $showingSheet, onDismiss: saveMaterial) {
            if self.activeSheet == .photo {
                ImagePicker(image: self.$inputImage)
            } else if self.activeSheet == .audio {
                AudioRecorderView(audioRecorder: AudioRecorder(), audioURL: self.$audioURL)
            } else if self.activeSheet == .video {
                CameraViewController()
            } else {
                AddLocationMapView(address: "", location: nil).environmentObject(self.locationData)
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = inputImage
    }
    
    func loadAudio() {
        
    }
    
    func loadVideo() {
        self.videoURL = CameraController.shared.videoURL
    }
    
    func loadLocation() {
        
    }
    
    func saveMaterial() {
        switch activeSheet {
        case .photo:
            loadImage()
        case .audio:
            loadAudio()
        case .video:
            loadVideo()
        case .location:
            loadLocation()
        }
        
        self.showingSheet = false
    }
    
    func post() {
        if !experienceTitleText.isEmpty {
            let experience = Experience(title: self.experienceTitleText, photo: self.inputImage, audioURL: self.audioURL, videoURL: self.videoURL, latitude: locationData.location?.coordinate.latitude, longitude: locationData.location?.coordinate.longitude)
            
            self.data.experiences.append(experience)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        AddExperienceView(latitude: 0, longitude: 0).environmentObject(ExperienceData())
    }
}

struct DoneButtonView: View {
    var body: some View {
        HStack {
            HStack {
                Text("Post")
                    .font(.body)
                Image(systemName: "checkmark")
            }
            .frame(width: screen.width - 40, height: screen.width / 8)
            .background(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
            Spacer()
            
        }
        .foregroundColor(.white)
        .frame(width: screen.width - 40, height: screen.width / 8)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .background(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)), lineWidth: 4))
        .shadow(color: .black, radius: 1, x: 0, y: 3)
    .padding()
    }
}
