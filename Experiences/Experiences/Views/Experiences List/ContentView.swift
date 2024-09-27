//
//  ContentView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/17/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: ExperienceData
    @State var addButtonIsTapped = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(data.experiences, id: \.self) { experience in
                    NavigationLink(destination: ExperienceView(experience: experience)) {
                        ExperienceRow(experience: experience.title)
                    }
                }
            }
            .sheet(isPresented: $addButtonIsTapped, onDismiss: resetAddButtonBool, content: {
                AddExperienceView(latitude: 0, longitude: 0).environmentObject(self.data).environmentObject(LocationData())
            })
            .navigationBarTitle("Experiences")
            .navigationBarItems(trailing:
                Button(action: {
                    self.addButtonIsTapped.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                })
            )
        }
    }
    
    func resetAddButtonBool() {
        addButtonIsTapped = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ExperienceData())
    }
}

let screen = UIScreen.main.bounds
