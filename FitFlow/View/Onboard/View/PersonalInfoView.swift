//
//  PersonalInfoView.swift
//  FitFlow
//
//  Created by Engin Bolat on 23.12.2025.
//

import SwiftUI

struct PersonalInfoView: View {
    @Binding var name: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(localizable: .welcomeToFitFlow).font(.largeTitle).bold()
            TextField(LocalizableEnum.whatIsYourName.key, text: $name)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
        }
    }
}

#Preview {
    PersonalInfoView(name: .constant(""))
        .padding(20)
}
