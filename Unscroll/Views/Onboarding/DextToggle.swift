//
//  DextToggle.swift
//  Unscroll
//
//  Created by Sebastian on 27/06/2026.
//

import SwiftUI

struct DextToggle: View {
    @Environment(DiagnosticsManager.self) private var diagnosticsManager
    
    var body: some View {
        Toggle("Aktivér systemudvidelsen", isOn: Binding(get: { diagnosticsManager.dextState == .success(.active) }, set: { newValue in
            if newValue {
                switch diagnosticsManager.dextState {
                case .success(.requiresUserApproval):
                    diagnosticsManager.openSystemExtensionsSettings()
                case .success(.active):
                    break
                default:
                    diagnosticsManager.activateSystemExtension()
                }
            } else {
                diagnosticsManager.deactivateSystemExtension()
            }
        }))
    }
}

#Preview {
    @Previewable @State var diagnosticsManager = DiagnosticsManager()
    
    DextToggle()
        .environment(diagnosticsManager)
}
