//
//  ExperienceRow.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/23/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI

struct ExperienceRow: View {
    var experience: String
    
    var body: some View {
        HStack {
            Text(experience)
                .font(.headline)
                .padding()
            
            Spacer()
        }
    }
}

struct ExperienceRow_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceRow(experience: "New Experience")
    }
}
