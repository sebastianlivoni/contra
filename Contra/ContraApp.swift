//
//  ContraApp.swift
//  Contra
//
//  Created by Sebastian on 25/06/2026.
//

import SwiftUI

@main
struct ContraApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var diagnosticsManager = DiagnosticsManager()
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding: Bool = false
    
    var body: some Scene {
        Window(.main) {
            Text("Hello, World!")
                .frame(width: 350, height: 460)
                .environment(diagnosticsManager)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands { ContraCommands() }
        .defaultLaunchBehavior(hasShownOnboarding ? .presented : .suppressed)
        
        Window( .onboarding) {
            OnboardingFlowContainer()
                .environment(diagnosticsManager)
                .applyVisualEffect()
                .stripTrafficLights()
                .gesture(WindowDragGesture()) // Lets users drag anywhere to move the window
                .centerWindow(.onboarding)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultLaunchBehavior(!hasShownOnboarding ? .presented : .suppressed)
        
        Window(.about) {
            AboutView()
                .applyVisualEffect()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultLaunchBehavior(.suppressed)
        .commandsRemoved()
        
        Settings {
            SettingsView().environment(diagnosticsManager)
        }
    }
}

enum AppWindow: String {
    case main
    case onboarding
    case about

    var title: LocalizedStringResource {
        switch self {
        case .main:
            "Contra"
        case .onboarding:
            "Welcome to Contra"
        case .about:
            "About"
        }
    }

    var id: String { rawValue }
}

extension Window where Content: View {
    init(_ appWindow: AppWindow, @ViewBuilder content: () -> Content) {
        self.init(appWindow.title, id: appWindow.id, content: content)
    }
}

extension View {
    func stripTrafficLights() -> some View {
        self.onAppear {
            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "onboarding" }) {
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.collectionBehavior = [.fullScreenNone]
                window.styleMask.remove(.resizable)
            }
        }
    }
    
    func centerWindow(_ appWindow: AppWindow) -> some View {
        self.onAppear {
            guard let window = NSApplication.shared.windows.first(where: {
                $0.identifier?.rawValue == appWindow.id
            }) else { return }

            window.center()
        }
    }
}
