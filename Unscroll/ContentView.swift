//
//  ContentView.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import SwiftUI

struct ContentView: View {
    let manager = SystemExtensionManager()
    let virtual = VirtualDevice()
    
    var body: some View {
        ScrollView {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button("Activate & Install") {
                Task {
                    manager.activate()
                }
            }
            
            Button("Activate Virtual Device") {
                Task {
                    await virtual.activate()
                }
            }
            
            Button("Scroll up") {
                Task {
                    await virtual.scrollUp()
                }
            }
            
            Button("Scroll down") {
                Task {
                    await virtual.scrollDown()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
