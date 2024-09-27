//
//  AddLocationCellView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/19/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct AddLocationCellView: View {
    var body: some View {
        
        
        HStack {
            HStack {
                Text("Add a Location")
                    .font(.body)
                Image(systemName: "mappin.and.ellipse")
            }
            .frame(width: screen.width - 40, height: screen.width / 8)
            .background(Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)))
            Spacer()
        }
        .foregroundColor(Color(#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)))
        .frame(width: screen.width - 40, height: screen.width / 8)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .background(Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)), lineWidth: 4))
        .shadow(color: .black, radius: 1, x: 0, y: 3)
    .padding()
    }
}

struct AddLocationCellView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationCellView()
    }
}
