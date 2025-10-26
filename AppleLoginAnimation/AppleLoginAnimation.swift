//
//  AppleLoginAnimation.swift
//  AppleLoginAnimation
//
//  Created by George on 14/10/2025.
//

import SwiftUI

struct AppleLoginAnimation: View {
    let logo: String
    let images: [String]
    
    var body: some View {
        ZStack {
            AnimatedLogoOrbit(
                images: images
            )
            
            Image(logo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .offset(x: 0, y: -5)
        }
        .ignoresSafeArea()
        .padding()
    }
}

#Preview {
    AppleLoginAnimation(
        logo: "apple",
        images: ["messages", "app-store", "find-my", "music", "cloud", "files", "wallet", "photos"]
    )
}
