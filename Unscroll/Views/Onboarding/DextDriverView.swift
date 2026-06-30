//
//  DextDriverView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct DextDriverView: View {
    @Binding var progress: OnboardingProgress
    @Environment(DiagnosticsManager.self) private var diagnosticsManager
    @State private var showContinuePopover = false
    
    var body: some View {
        VStack(spacing: 20) {
            OnboardingHeader(title: "Vend musehjulets retning", description: "Får din eksterne mus til at rulle som på Windows.")
            
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Aktivér systemudvidelsen")
                        Text("Nødvendig for at vende rulleretningen").foregroundStyle(.secondary)
                    }
                    Spacer()
                    DextToggle().toggleStyle(.switch).labelsHidden()
                }.padding(8)
            }.frame(width: 400)
            
            HStack(spacing: 10) {
                Button { progress = .safariExtension } label: {
                    Text("Jeg gør det senere")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.glass)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                
                Button {
                    if diagnosticsManager.dextState != .success(.active) {
                        showContinuePopover = true
                    } else {
                        progress = .safariExtension
                    }
                } label: {
                    Text("Fortsæt")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.glassProminent)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .popover(isPresented: $showContinuePopover, arrowEdge: .bottom) {
                    PopoverWarning(
                        title: "Systemudvidelsen er ikke aktiv",
                        text: "Unscroll virker ikke, før systemudvidelsen er aktiveret. Aktivér den nu for at fortsætte.",
                        actionText: "Aktivér nu",
                        onAction: { diagnosticsManager.activateSystemExtension() },
                        onSkip: { progress = .safariExtension }
                    )
                }
            }
        }
        .frame(width: 544, height: 670)
    }
}

#Preview {
    @Previewable @State var diagnosticsManager = DiagnosticsManager()
    
    DextDriverView(progress: .constant(.dextDriver))
        .environment(diagnosticsManager)
}
