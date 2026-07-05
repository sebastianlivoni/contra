//
//  ContraCommands.swift
//  Contra
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct ContraCommands: Commands {
    @Environment(\.openWindow) var openWindow
    
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Contra", systemImage: "info.circle") {
                openWindow(id: "about")
            }
        }
    }
}
