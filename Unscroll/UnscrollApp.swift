//
//  UnscrollApp.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import SwiftUI

@main
struct UnscrollApp: App {
    var body: some Scene {
        Window("Unscroll", id: "unscroll") {
            ContentView()
                .frame(width: 350, height: 460)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
