//
//  CircleImage.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/17/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    var image: Image

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: screen.width / 1.5, height: screen.width / 1.5)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE (2nd generation)", "iPhone 11", "iPhone 11 Pro Max"], id: \.self) { deviceName in
            CircleImage(image: Image("turtlerock"))
                .previewDevice(PreviewDevice(rawValue: deviceName))
        }
    }
}
