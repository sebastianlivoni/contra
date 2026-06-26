//
//  WelcomeView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

//
//  WelcomeView.swift
//  Unscroll
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                if let image = NSImage(named: "AppIcon") {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160)
                        .cornerRadius(8)
                }
                
                VStack(spacing: 8) {
                    Text("En bedre måde at kopiere og indsætte")
                        .fontWeight(.bold)
                        .font(.title)
                    
                    Text("Unscroll er en tidsmaskine til dit udklipsholder, som lader dig finde alt, hvad du nogensinde har kopieret, og bruge det når som helst, når du har brug for det igen.")
                }
                
                NavigationLink {
                    
                } label: {
                    Text("Kom godt i gang")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)
                .padding(.top, 15)
            }
            .multilineTextAlignment(.center)
            .padding(45)
            .frame(width: 544)
            .frame(minHeight: 450, maxHeight: .infinity)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    WelcomeView()
}
