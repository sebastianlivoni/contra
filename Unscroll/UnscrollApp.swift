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
    
    var body: some Scene {
        Window("Unscroll", id: "unscroll") {
            ContentView()
                .frame(width: 350, height: 460)
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
        .windowResizability(.contentSize)
    }
}
