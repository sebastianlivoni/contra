//
//  SafariExtensionView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct SafariExtensionView: View {
    @Binding var progress: OnboardingProgress
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding: Bool = false
    @Environment(DiagnosticsManager.self) private var diagnosticsManager
    @State private var showContinuePopover = false
    
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 20) {
            OnboardingHeader(title: "Gå frem og tilbage", description: "Vis forrige eller næste side i Safari med sideknapperne på din mus.")
            
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Aktivér Safari webudvidelsen")
                        Text("Nødvendig for bruge sideknapperne på din mus i Safari").foregroundStyle(.secondary)
                    }
                    Spacer()
                    SafariExtensionToggle().toggleStyle(.switch).labelsHidden()
                }.padding(8)
            }.frame(width: 400)
            
            HStack(spacing: 10) {
                Button { completeOnboarding() } label: {
                    Text("Jeg gør det senere")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.glass)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                
                Button {
                    if diagnosticsManager.safariExtensionState != .success(.enabled) {
                        showContinuePopover = true
                    } else {
                        completeOnboarding()
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
                        title: "Safari web-udvidelsen er ikke aktiv",
                        text: "Unscroll virker ikke, før Safari webudvidelsen er aktiveret. Aktivér den nu for at fortsætte.",
                        actionText: "Aktivér nu",
                        onAction: { diagnosticsManager.openSafariExtensionSettings() },
                        onSkip: { completeOnboarding() }
                    )
                }
            }
        }
        .frame(width: 544, height: 670)
    }
    
    private func completeOnboarding() {
        progress = .completed
        hasShownOnboarding = true
        openWindow(id: AppWindow.main.id)
        dismissWindow(id: AppWindow.onboarding.id)
    }
}

#Preview {
    @Previewable @State var diagnosticsManager = DiagnosticsManager()
    
    SafariExtensionView(progress: .constant(.safariExtension))
        .environment(diagnosticsManager)
}
