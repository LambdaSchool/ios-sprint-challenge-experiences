//
//  ExperienceView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/17/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI
import MapKit

struct ExperienceView: View {
    @State var experience: Experience
    
    var body: some View {
        ZStack {
                VStack {
                    VStack {
                        MapView(latitude: experience.latitude ?? 37.3230, longitude: experience.longitude ?? 122.0322, experience: experience)
                            .frame(width: screen.width, height: screen.height / 2.5)
                        
                        if experience.photo != nil {
                            CircleImage(image: Image(uiImage: experience.photo ?? UIImage(systemName: "person.circle")!))
                            .offset(y: -(screen.height / 6))
                        }
                        
                        HStack {
                            Text(experience.title)
                                .font(.title)
                                .bold()
                                .padding()
                            
                            Spacer()
                        }
                        
                        if experience.audioURL != nil {
                            AudioPlayer(sliderValue: 0.0, audioPlayerObject: AudioPlayerObject(), audioURL: experience.audioURL)
                        }
                        
                        if experience.videoURL != nil {
                            NavigationLink(destination: PlayerView(experience: self.experience)) {
                                Text("Play Video")
                            }
                        }
                        
                        Spacer()
                    }
                }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE (2nd generation)", "iPhone 11", "iPhone 11 Pro Max"], id: \.self) { deviceName in
            ExperienceView(experience: Experience(title: "Test New Experience", photo: nil, audioURL: nil, videoURL: nil, latitude: nil, longitude: nil))
                .previewDevice(PreviewDevice(rawValue: deviceName))
        }
    }
}
