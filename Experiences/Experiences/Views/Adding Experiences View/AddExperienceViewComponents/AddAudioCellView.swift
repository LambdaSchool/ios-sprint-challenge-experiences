//
//  AddAudioCellView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/19/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct AddAudioCellView: View {
    var body: some View {
        
        
        HStack {
            HStack {
                HStack {
                    Text("Add Audio")
                        .font(.body)
                    Image(systemName: "mic")
                }
                .frame(width: screen.width - 40, height: screen.width / 8)
                .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
            }
            Spacer()
        }
        .foregroundColor(.white)
        .frame(width: screen.width - 40, height: screen.width / 8)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 4))
        .shadow(color: .black, radius: 1, x: 0, y: 3)
    .padding()
    }
}

struct AddAudioCellView_Previews: PreviewProvider {
    static var previews: some View {
        AddAudioCellView()
    }
}
