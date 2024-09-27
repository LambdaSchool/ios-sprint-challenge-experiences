//
//  SaveLocationCellView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/23/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct SaveLocationCellView: View {
    var body: some View {
        HStack {
            HStack {
                Text("Save Location")
                    .font(.body)
                Image(systemName: "mappin")
            }
            .frame(width: screen.width - 40, height: screen.width / 8)
            .background(Color.blue)
            Spacer()
            
        }
        .foregroundColor(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))
        .frame(width: screen.width - 40, height: screen.width / 8)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .background(Color.blue)
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), lineWidth: 4))
        .shadow(color: .black, radius: 1, x: 0, y: 3)
        .padding()
    }
}

struct SaveLocationCellView_Previews: PreviewProvider {
    static var previews: some View {
        SaveLocationCellView()
    }
}
