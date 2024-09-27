//
//  AddVideoCellView.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/19/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct AddVideoCellView: View {
    var body: some View {
        
        
        HStack {
            HStack {
                Text("Add a Video")
                    .font(.body)
                Image(systemName: "video")
            }
            .frame(width: screen.width - 40, height: screen.width / 8)
            .background(Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)))
            Spacer()
        }
        .foregroundColor(Color(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)))
        .frame(width: screen.width - 40, height: screen.width / 8)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .background(Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)), lineWidth: 4))
        .shadow(color: .black, radius: 1, x: 0, y: 3)
    .padding()
    }
}

struct AddVideoCellView_Previews: PreviewProvider {
    static var previews: some View {
        AddVideoCellView()
    }
}
