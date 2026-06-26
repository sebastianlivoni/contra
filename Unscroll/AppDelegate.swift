//
//  AppDelegate.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    /*var onboardingWindow: GlassBackgroundWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = GlassBackgroundWindow()
        self.onboardingWindow = window
        
        window.alphaValue = 1.0
        window.makeKeyAndOrderFront(nil)
        
        window.animatePopIn()
        
        NSApp.activate(ignoringOtherApps: true)
    }*/
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
