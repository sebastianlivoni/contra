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
            //ContentView()
            Text("Hello, World!")
                .frame(width: 350, height: 460)
                .environment(diagnosticsManager)
            
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            UnscrollCommands()
        }
        
        Window("Onboarding", id: "onboarding") {
            WelcomeView()
                .environment(diagnosticsManager)
                .applyVisualEffect()
                .windowMinimizeBehavior(.disabled)
                .windowDismissBehavior(.disabled)
                .windowResizeBehavior(.disabled)
                .movableByWindowBackground()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        Window("About", id: "about") {
            AboutView()
                .applyVisualEffect()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        Settings {
            SettingsView()
                .environment(diagnosticsManager)
        }
    }
}
