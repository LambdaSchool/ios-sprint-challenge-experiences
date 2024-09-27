//
//  AddPhotoCellView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/19/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct AddPhotoCellView: View {
    var body: some View {
        HStack {
            HStack {
                Text("Add a Photo")
                    .font(.body)
                Image(systemName: "camera.on.rectangle")
            }
            .frame(width: screen.width - 40, height: screen.width / 8)
            .background(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))
            Spacer()
            
        }
        .foregroundColor(.blue)
        .frame(width: screen.width - 40, height: screen.width / 8)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .background(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color.blue, lineWidth: 4))
        .shadow(color: .black, radius: 1, x: 0, y: 3)
        .padding()
    }
}

struct AddPhotoCellView_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoCellView()
    }
}
