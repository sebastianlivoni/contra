//
//  QuickStartView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct QuickStartView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    
    @State private var toggleDext: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                if let image = NSImage(named: "AppIcon") {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                        .cornerRadius(8)
                }
                
                VStack(spacing: 8) {
                    Text("Vend musehjulets retning")
                        .fontWeight(.bold)
                        .font(.title)
                    
                    Text("Får din eksterne mus til at rulle som på Windows.")
                }
                .frame(width: 400)
                .multilineTextAlignment(.center)
            }
            
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Aktivér systemudvidelsen")
                        Text("Nødvendig for at vende rulleretningen")
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                    
                    DextToggle()
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
                .padding([.leading, .trailing], 8)
                .padding([.top, .bottom], 4)
            }
            .padding(.top)
            .frame(width: 400)
            
            HStack(spacing: 10) {
                Button {
                    dismissWindow(id: "onboarding")
                } label: {
                    Text("Jeg gør det senere")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .fontWeight(.medium)
                }
                .buttonStyle(.glass)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                
                Button {
                    dismissWindow(id: "onboarding")
                } label: {
                    Text("Fortsæt")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .fontWeight(.medium)
                }
                .buttonStyle(.glassProminent)
                .clipShape(RoundedRectangle(cornerRadius: 50))
            }
            .padding(.top, 15)
        }
        .frame(width: 540, height: 650)
    }
}

#Preview {
    @Previewable @State var diagnosticsManager = DiagnosticsManager()
    
    QuickStartView()
        .environment(diagnosticsManager)
}
