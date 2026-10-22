//
//  LoaderView.swift
//  FitFlow
//
//  Created by Engin Bolat on 24.12.2025.
//

import SwiftUI

struct LoaderView: View {
    var body: some View {
        VStack {
            Color.gray.opacity(0.8)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .overlay {
            ProgressView()
                .tint(.white)
                .controlSize(.large)
            
        }
    }
}

#Preview() {
    ZStack {
        Text("allalal")
        LoaderView()
    }
}
