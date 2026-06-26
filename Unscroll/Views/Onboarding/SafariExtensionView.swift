//
//  SafariExtensionView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct SafariExtensionView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    
    @Environment(DiagnosticsManager.self) private var diagnosticsManager
    
    @State private var showContinuePopover = false
    
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
                    Text("Gå frem og tilbage")
                        .fontWeight(.bold)
                        .font(.title)
                    
                    Text("Vis forrige eller næste side i Safari med sideknapperne på din mus.")
                }
                .frame(width: 400)
                .multilineTextAlignment(.center)
            }
            
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Aktivér Safari webudvidelsen")
                        Text("Nødvendig for bruge sideknapperne på din mus i Safari")
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                    
                    SafariExtensionToggle()
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
                    if diagnosticsManager.dextState != .success(.active) {
                        showContinuePopover = true
                    } else {
                        dismissWindow(id: "onboarding")
                    }
                } label: {
                    Text("Fortsæt")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .fontWeight(.medium)
                }
                .buttonStyle(.glassProminent)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .popover(isPresented: $showContinuePopover, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Safari web-udvidelsen er ikke aktiv", systemImage: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.subheadline).fontWeight(.medium)

                        Text("Unscroll virker ikke, før Safari webudvidelsen er aktiveret. Aktivér den nu for at fortsætte.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()

                        Button {
                            showContinuePopover = false
                            // trigger your DextToggle / activate extension
                            diagnosticsManager.activateSystemExtension()
                        } label: {
                            Text("Aktivér nu")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)

                        Button {
                            showContinuePopover = false
                            dismissWindow(id: "onboarding")
                        } label: {
                            Text("Fortsæt alligevel")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(width: 260)
                }
            }
            .padding(.top, 15)
        }
        .frame(width: 540, height: 650)
    }
}

#Preview {
    @Previewable @State var diagnosticsManager = DiagnosticsManager()
    
    SafariExtensionView()
        .environment(diagnosticsManager)
}
