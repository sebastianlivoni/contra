//
//  SettingsView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                GeneralSettingsView()
            }
            Tab("Diagnostics", systemImage: "stethoscope") {
                DiagnosticsSettingsView()
                    .frame(height: 300)
            }
        }
        .scenePadding()
        .scrollDisabled(true)
        .frame(width: 350)
    }
}

#Preview {
    SettingsView()
}
