//
//  AddLocationMapView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/23/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI
import MapKit

struct AddLocationMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var locationData: LocationData
    @State var address: String
    @State var location: CLLocation?
    
    var body: some View {
        VStack {
            TextField("Enter an address...", text: $address)
                .frame(height: 30)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)), lineWidth: 1).shadow(color: .black, radius: 3, x: 0, y: 3))
                .padding(8)
            
            Button(action: {
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(self.address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                    }
                    // Use your location
                    self.location = location
                }
            }) {
                Text("Check Address")
            }
            
            MapView(
                latitude: location?.coordinate.latitude ?? 40.898920,
                longitude: location?.coordinate.longitude ?? -111.851120
            )
                .frame(height: screen.height / 2)
            
            Spacer()
            
            Button(action: {
                self.locationData.location = self.location
                self.presentationMode.wrappedValue.dismiss()
            }) {
                SaveLocationCellView()
            }
        }
    }
}

struct AddLocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationMapView(address: "")
    }
}
