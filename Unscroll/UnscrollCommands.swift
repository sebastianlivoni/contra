//
//  UnscrollCommands.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct UnscrollCommands: Commands {
    @Environment(\.openWindow) var openWindow
    
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Unscroll", systemImage: "info.circle") {
                openWindow(id: "about")
            }
        }
    }
}
