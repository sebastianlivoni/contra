//
//  DiagnosticsManager.swift
//  Contra
//
//  Created by Sebastian on 26/06/2026.
//

import Foundation
import SwiftUI
import Combine
import SafariServices
import os.log
import SystemExtensions

enum DextStatus: Equatable {
    case active
    case inactive
    case disabled
    case requiresUserApproval
    case requiresReboot
}

enum SafariExtensionStatus: Equatable {
    case enabled
    case disabled
}

enum DiagnosticState<T: Equatable>: Equatable {
    case unknown
    case fetching
    case success(T)
}

@Observable
@MainActor
final class DiagnosticsManager: NSObject, OSSystemExtensionRequestDelegate, OSSystemExtensionsWorkspaceObserver {
    var naturalScrollingState: DiagnosticState<Bool> = .unknown
    var safariExtensionState: DiagnosticState<SafariExtensionStatus> = .unknown
    var dextState: DiagnosticState<DextStatus> = .unknown
    
    private var cancellables = Set<AnyCancellable>()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: DiagnosticsManager.self))
    
    private let safariExtensionIdentifier = "me.livoni.Contra.SafariExtension"
    private let driverIdentifier = "me.livoni.Contra.ContraDriver"
    
    override init() {
        super.init()
        
        naturalScrollingState = .fetching
        safariExtensionState = .fetching
        dextState = .fetching
        
        checkAllStatuses()
        
        NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkAllStatuses()
            }
            .store(in: &cancellables)
        
        setupWorkspaceObserver()
    }
    
    func checkAllStatuses() {
        Task {
            async let checkScroll: Void = checkNaturalScrolling()
            async let checkSafari: Void = checkSafariExtensionStatus()
            
            let _ = await (checkScroll, checkSafari)
        }
        
        queryExtensionProperties()
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
            self.safariExtensionState = .success(result.isEnabled ? .enabled : .disabled)
        } catch {
            logger.error("Failed to check safari extension status: \(error.localizedDescription)")
            self.safariExtensionState = .unknown
        }
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
    func openSystemExtensionsSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension?ExtensionItems") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // TODO: Make it open the scrolling settings correctly
    func openSystemScrollingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Trackpad-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - System Extension
    func activateSystemExtension() {
        let request = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: driverIdentifier, queue: DispatchQueue.main)
        request.delegate = self
        logger.debug("Submitting activation request for system extension")
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    func deactivateSystemExtension() {
        let request = OSSystemExtensionRequest.deactivationRequest(forExtensionWithIdentifier: driverIdentifier, queue: DispatchQueue.main)
        request.delegate = self
        logger.debug("Submitting deactivation request for system extension")
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    private func setupWorkspaceObserver() {
        do {
            logger.debug("Adding workspace observer for system extension")
            try OSSystemExtensionsWorkspace.shared.addObserver(self)
        } catch {
            logger.error("Failed to add workspace observer: \(error.localizedDescription)")
        }
    }
    
    deinit {
        logger.debug("Removing workspace observer for system extension")
        OSSystemExtensionsWorkspace.shared.removeObserver(self)
    }
    
    func queryExtensionProperties() {
        let request = OSSystemExtensionRequest.propertiesRequest(
            forExtensionWithIdentifier: driverIdentifier,
            queue: DispatchQueue.main
        )
        request.delegate = self
        logger.debug("Submitting properties request for system extension")
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    // MARK: - OSSystemExtensionRequestDelegate
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        logger.debug("Replacing system extension")
        return .replace
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        logger.debug("System extension requires user approval")
        dextState = .success(.requiresUserApproval)
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        switch result {
        case .completed:
            logger.debug("System extension finished with completed")
            dextState = .success(.active)
        case .willCompleteAfterReboot:
            logger.debug("System extension finished with will complete after reboot")
            dextState = .success(.requiresReboot)
        default:	
            logger.debug("System extension finished with unknown result \(result.rawValue)")
            dextState = .unknown
        }
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: any Error) {
        logger.error("System extension request failed with error: \(error.localizedDescription)")
        dextState = .unknown
    }
    
    func request(_ request: OSSystemExtensionRequest, foundProperties properties: [OSSystemExtensionProperties]) {
        var detectedStatus: DextStatus? = nil
        
        for prop in properties {
            if prop.isEnabled {
                detectedStatus = .active
                logger.debug("System extension is active (system extension properties)")
                break
            } else if prop.isAwaitingUserApproval {
                logger.debug("System extension requires user approval (system extension properties)")
                detectedStatus = .requiresUserApproval
            } else if prop.isUninstalling && detectedStatus == nil {
                logger.debug("System extension is uninstalling (system extension properties)")
                detectedStatus = .inactive
            }
        }
        
        if let status = detectedStatus {
            self.dextState = .success(status)
        } else {
            self.dextState = .unknown
        }
    }
    
    // MARK: - OSSystemExtensionsWorkspaceObserver
    nonisolated func systemExtensionWillBecomeEnabled(_ systemExtensionInfo: OSSystemExtensionInfo) {
        logger.debug("System extension will become enabled")
        Task { @MainActor in
            dextState = .success(.active)
        }
    }

    nonisolated func systemExtensionWillBecomeDisabled(_ systemExtensionInfo: OSSystemExtensionInfo) {
        logger.debug("System extension will become disabled")
        Task { @MainActor in
            dextState = .success(.disabled)
        }
    }

    nonisolated func systemExtensionWillBecomeInactive(_ systemExtensionInfo: OSSystemExtensionInfo) {
        logger.debug("System extension will become inactive")
        Task { @MainActor in
            dextState = .success(.inactive)
        }
    }
}
