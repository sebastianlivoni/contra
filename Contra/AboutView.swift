//
//  AboutView.swift
//  Contra
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct AboutView: View {
    let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? "Unknown"
    
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
    let copyright = Bundle.main.localizedInfoDictionary?["NSHumanReadableCopyright"] as? String ?? "Unknown"
    
    var body: some View {
        HStack(spacing: 30) {
            if let image = NSImage(named: "AppIcon") {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                Text(displayName)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Version \(version) (\(bundleVersion))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(copyright)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 15)
                    .frame(width: 250)
                
                HStack {
                    Button("Third-party licenses") {
                        if let url = Bundle.main.url(forResource: "Third-party licenses", withExtension: "pdf") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .font(.callout)
                    .buttonStyle(.bordered)
                }
                .padding([.top], 5)
            }
        }
        .padding([.leading, .trailing], 5)
        .frame(width: 450, height: 170)
    }
}

#Preview {
    AboutView()
}
