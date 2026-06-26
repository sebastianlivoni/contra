//
//  DiagnosticsManager.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import Foundation
import SwiftUI
import Combine
import SafariServices
import os.log

enum DiagnosticState<T> {
    case unknown       // Initial state before check runs
    case fetching      // Actively pulling information
    case success(T)    // Successfully retrieved the state
}

@Observable
@MainActor
class DiagnosticsManager {
    var naturalScrollingState: DiagnosticState<Bool> = .unknown
    var safariExtensionState: DiagnosticState<Bool> = .unknown
    var dextState: DiagnosticState<Bool> = .unknown
    
    private var cancellables = Set<AnyCancellable>()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: DiagnosticsManager.self))
    
    private let safariExtensionIdentifier = "me.livoni.Unscroll.SafariExtension"
    
    init() {
        naturalScrollingState = .fetching
        safariExtensionState = .fetching
        dextState = .fetching
        
        checkAllStatuses()
        
        NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkAllStatuses()
            }
            .store(in: &cancellables)
    }
    
    func checkAllStatuses() {
        Task {
            async let checkScroll: Void = checkNaturalScrolling()
            async let checkSafari: Void = checkSafariExtensionStatus()
            async let checkDext: Void = checkDextStatus()
            
            let _ = await (checkScroll, checkSafari, checkDext)
        }
    }
    
    private func checkNaturalScrolling() async {
            // com.apple.swipescrolldirection: 1 = Natural, 0 = Traditional
            let defaults = UserDefaults.standard
            let persistentDomain = defaults.persistentDomain(forName: UserDefaults.globalDomain)
            if let swipeDirection = persistentDomain?["com.apple.swipescrolldirection"] as? Int {
                self.naturalScrollingState = .success(swipeDirection == 1)
            } else {
                self.naturalScrollingState = .unknown
            }
        }
    
    func checkSafariExtensionStatus() async {
        do {
            let result = try await SFSafariExtensionManager.stateOfSafariExtension(withIdentifier: safariExtensionIdentifier)
            self.safariExtensionState = .success(result.isEnabled)
        } catch {
            logger.error("Failed to check safari extension status: \(error.localizedDescription)")
            self.safariExtensionState = .unknown
        }
    }
    
    func checkDextStatus() async {
        // Simulating the dext check delay. Replace with your structural IOKit service verification.
        try? await Task.sleep(for: .milliseconds(400))
        self.dextState = .success(true)
    }
    
    func openSafariExtensionSettings() {
        Task {
            do {
                try await SFSafariApplication.showPreferencesForExtension(withIdentifier: safariExtensionIdentifier)
            } catch {
                logger.error("Error opening Safari extension settings: \(error.localizedDescription)")
            }
        }
    }
    
    // TODO: Make it open the DEXT settings correctly
    func openSystemDextSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Trackpad-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // TODO: Make it open the scrolling settings correctly
    func openSystemScrollingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Trackpad-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}

/*class DiagnosticsManager: ObservableObject {
    @Published var isNaturalScrollingEnabled: Bool = false
    @Published var isSafariExtensionEnabled: Bool = false
    @Published var isDextActive: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    // Replace with your Safari Extension's Bundle Identifier
    private let safariExtensionIdentifier = "me.livoni.Unscroll.SafariExtension"
    
    init() {
        checkAllStatuses()
        
        // Listen for the app coming to the foreground to re-check states
        // (e.g., if the user just returned from Safari or System Settings)
        NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkAllStatuses()
            }
            .store(in: &cancellables)
    }
    
    func checkAllStatuses() {
        checkNaturalScrolling()
        checkSafariExtensionStatus()
        checkDextStatus()
    }
    
    /// Reads the global macOS domain for scroll direction
    private func checkNaturalScrolling() {
        // com.apple.swipescrolldirection: 1 = Natural, 0 = Traditional
        let defaults = UserDefaults.standard
        let persistentDomain = defaults.persistentDomain(forName: UserDefaults.globalDomain)
        if let swipeDirection = persistentDomain?["com.apple.swipescrolldirection"] as? Int {
            self.isNaturalScrollingEnabled = (swipeDirection == 1)
        } else {
            // Default macOS behavior fallback if reading fails
            self.isNaturalScrollingEnabled = true
        }
    }
    
    /// Checks if the Safari Extension is checked in Safari Preferences
    private func checkSafariExtensionStatus() {
        /*SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: safariExtensionIdentifier) { [weak self] state, error in
            DispatchQueue.main.async {
                if let state = state {
                    self?.isSafariExtensionEnabled = state.isEnabled
                } else {
                    self?.isSafariExtensionEnabled = false
                }
            }
        }*/
    }
    
    /// Checks if your DriverKit driver is responsive
    private func checkDextStatus() {
        // Implement your IOKit / DriverKit UserClient connection check here.
        // E.g., checking if IOServiceMatching your dext returns an active object.
        // For demonstration, we'll keep it as a simulated state or mock check.
        self.isDextActive = true
    }
    
    /// Directs the user directly to Safari's Extension preferences panel
    func openSafariExtensionSettings() {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: safariExtensionIdentifier) { error in
            if let error = error {
                print("Error opening Safari extension settings: \(error.localizedDescription)")
            }
        }
    }
    
    /// Opens the Keyboard/Mouse system panel (where scrolling options sit)
    func openSystemScrollingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Trackpad-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}
*/
