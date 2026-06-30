//
//  Resuable.swift
//  Unscroll
//
//  Created by Sebastian on 28/06/2026.
//

import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            if let image = NSImage(named: "AppIcon") {
                Image(nsImage: image).resizable().frame(width: 80, height: 80).cornerRadius(8)
            }
            Text(title).fontWeight(.bold).font(.title)
            Text(description)
        }
        .frame(width: 400)
        .multilineTextAlignment(.center)
    }
}

// Common Warning Popover
struct PopoverWarning: View {
    let title: String
    let text: String
    let actionText: String
    let onAction: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.multicolor).font(.subheadline).fontWeight(.medium)
            Text(text).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            Divider()
            Button(actionText) { onAction() }.buttonStyle(.borderedProminent).controlSize(.small)
            Button("Fortsæt alligevel") { onSkip() }.buttonStyle(.plain).font(.caption).foregroundStyle(.secondary)
        }
        .padding(16).frame(width: 260)
    }
}
