//
//  ContentView.swift
//  AppleLoginAnimation
//
//  Created by George on 14/10/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AppleLoginAnimation(
            logo: "apple",
            images: ["messages", "app-store", "find-my", "music", "cloud", "files", "wallet", "photos"]
        )
    }
}

#Preview {
    ContentView()
}
