//
//  SetupView.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct SetupView: View {
    @State private var extensionManager = SystemExtensionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            switch extensionManager.uiState {
                
            case .checking:
                ProgressView("Checking driver status...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .needsActivation:
                VStack(spacing: 12) {
                    Image(systemName: "puzzlepiece.extension")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text("Enable Unscroll Driver")
                        .font(.headline)
                    Text("Unscroll requires a system driver extension to hook up your mouse features.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Install Driver") {
                        extensionManager.activate()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
            case .waitingForUser:
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("Action Required")
                        .font(.headline)
                    
                    // Simple, direct visual steps for the user
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Open **System Settings**.")
                        Text("2. Navigate to **Privacy & Security**.")
                        Text("3. Scroll down and click **Allow** next to UnscrollDriver.")
                    }
                    .font(.subheadline)
                    
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Waiting for approval...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
            case .enabled:
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Driver fully active!")
                        .font(.headline)
                    Text("Your mouse wheel will now scroll as expected")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .frame(width: 350, height: 250)
    }
}
