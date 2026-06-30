//
//  PreferencesView2.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import SwiftUI

struct PreferencesView: View {
    // Existing system tracking
    //@State private var naturalScrollingStatus: String = ScrollPreferences.scrollingDirectionString
    
    // New states for driver control and external mouse preferences
    @State private var isDriverEnabled: Bool = true
    @State private var externalMouseDirection: MouseScrollDirection = .natural

    enum MouseScrollDirection: String, CaseIterable, Identifiable {
        case natural = "Natural (Content moves with fingers)"
        case traditional = "Traditional (Content moves opposite)"
        
        var id: String { self.rawValue }
    }

    var body: some View {
        Form {
            // MARK: - Driver Settings
            Section(header: Text("Driver Status")) {
                Toggle(isOn: $isDriverEnabled) {
                    Text("Enable Unscroll Mouse Driver")
                }
                .toggleStyle(.switch)
                .onChange(of: isDriverEnabled) { _, newValue in
                    // Call your driver management logic here
                    // e.g., DriverKitManager.shared.setDriverEnabled(newValue)
                }
            }
            
            // MARK: - External Mouse Settings
            Section(header: Text("External Mouse Settings")) {
                Picker("Scroll Direction:", selection: $externalMouseDirection) {
                    ForEach(MouseScrollDirection.allCases) { direction in
                        Text(direction.rawValue).tag(direction)
                    }
                }
                .disabled(!isDriverEnabled) // Grey out if driver is off
                .onChange(of: externalMouseDirection) { _, newDirection in
                    // Call your scrolling modification logic here
                    // e.g., DriverKitManager.shared.updateDirection(newDirection)
                }
                
                Text("Independent of your MacBook trackpad settings.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // MARK: - System Overview
            Section(header: Text("System Information")) {
                HStack {
                    Text("Global System Scroll Direction:")
                    /*Text(naturalScrollingStatus)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)*/
                }
            }
        }
        .padding()
        .frame(width: 450, height: 250) // Expanded size to fit new controls comfortably
        /*.onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            naturalScrollingStatus = ScrollPreferences.scrollingDirectionString
        }*/
    }
}
