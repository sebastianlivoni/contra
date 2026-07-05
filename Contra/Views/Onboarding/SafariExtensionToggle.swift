//
//  SafariExtensionToggle.swift
//  Contra
//
//  Created by Sebastian on 27/06/2026.
//

import SwiftUI

struct SafariExtensionToggle: View {
    @Environment(DiagnosticsManager.self) private var diagnosticsManager
    
    var body: some View {
        Toggle("Aktivér Safari web-udvidelsen", isOn: Binding(get: { diagnosticsManager.safariExtensionState == .success(.enabled) }, set: { newValue in
            diagnosticsManager.openSafariExtensionSettings()
        }))
    }
}

#Preview {
    @Previewable @State var diagnosticsManager = DiagnosticsManager()
    
    DextToggle()
        .environment(diagnosticsManager)
}
