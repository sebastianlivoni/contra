//
//  DiagnosticsSettingsView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct DiagnosticsSettingsView: View {
    @Environment(DiagnosticsManager.self) var diagnosticsManager
    
    var body: some View {
        Form {
            Section(header: Text("Safari Web Extension")) {
                HStack {
                    StatusIndicator(state: diagnosticsManager.safariExtensionState)
                    
                    switch diagnosticsManager.safariExtensionState {
                    case .unknown:
                        Text("Unknown status")
                            .foregroundColor(.secondary)
                    case .fetching:
                        Text("Checking web extension status")
                            .foregroundColor(.secondary)
                    case .success(let isEnabled):
                        Text(isEnabled ? "Safari Web Extension is enabled" : "Safari Web Extension is disabled")
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
            }
            
            Section(header: Text("Scroll System Extension")) {
                HStack {
                    /*StatusIndicator(state: diagnosticsManager.dextState == .success(.active))
                    
                    switch diagnosticsManager.dextState {
                    case .unknown:
                        Text("Unknown status")
                            .foregroundColor(.secondary)
                    case .fetching:
                        Text("Checking scroll system extension status")
                            .foregroundColor(.secondary)
                    case .success(let isEnabled):
                        Text(isEnabled ? "System extension is enabled" : "System extension is disabled")
                            .foregroundColor(.primary)
                    }
                    Spacer()*/
                }
            }
            
            Section(header: Text("Scroll System Settings")) {
                HStack {
                    StatusIndicator(state: diagnosticsManager.naturalScrollingState)
                    
                    switch diagnosticsManager.naturalScrollingState {
                    case .unknown:
                        Text("Unknown status")
                            .foregroundColor(.secondary)
                    case .fetching:
                        Text("Checking scroll system settings status")
                            .foregroundColor(.secondary)
                    case .success(let naturalScrolling):
                        Text(naturalScrolling ? "Natural scrolling" : "Traditional scrolling")
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct StatusIndicator: View {
    let state: DiagnosticState<Bool>
    
    var color: Color {
        switch state {
        case .unknown:
            return .gray
        case .fetching:
            return .yellow
        case .success(let isActive):
            return isActive ? .green : .red
        }
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .shadow(color: color.opacity(0.4), radius: 2)
            .padding(.trailing, 6)
    }
}

#Preview {
    DiagnosticsSettingsView()
}
