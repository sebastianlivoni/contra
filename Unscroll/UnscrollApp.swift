//
//  UnscrollApp.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import SwiftUI

@main
struct UnscrollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var diagnosticsManager = DiagnosticsManager()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some Scene {
        Window("Unscroll", id: "unscroll") {
            ContentView()
                .frame(width: 350, height: 460)
                .environment(diagnosticsManager)
                .onAppear {
                    print("nice")
                    if let window = NSApp.windows.first(where: { $0.title == "Unscroll" }) {
                        window.orderOut(nil) // Hides it completely from sight without destroying it
                    }
                }
            
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            UnscrollCommands()
        }
        
        Window("About Unscroll", id: "about") {
            AboutView()
                .applyVisualEffect()
        }
        .commandsReplaced {
            CommandGroup(replacing: .singleWindowList) {
                EmptyView()
            }
        }
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
                .environment(diagnosticsManager)
        }
    }
}
