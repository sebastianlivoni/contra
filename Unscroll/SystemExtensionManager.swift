//
//  SystemExtensionManager.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import SystemExtensions
import Observation

enum ExtensionUIState {
    case checking           // Checking status on launch
    case needsActivation    // Show the "Activate Extension" setup button
    case waitingForUser     // Prompt user: "Go to System Settings > Privacy & Security to click Allow"
    case enabled            // Fully active! Show success / main UI
}

@Observable
final class SystemExtensionManager: NSObject, OSSystemExtensionRequestDelegate, OSSystemExtensionsWorkspaceObserver {
    let driverID = "me.livoni.Unscroll.UnscrollDriver"
    
    var uiState: ExtensionUIState = .checking
    
    // Internal tracking flag to separate properties evaluation from activation loops
    private var didFindActiveExtension = false
    
    override init() {
        super.init()
        
        setupWorkspaceObserver()
        activate()
    }
    
    private func setupWorkspaceObserver() {
        do {
            try OSSystemExtensionsWorkspace.shared.addObserver(self)
            print("Successfully registered workspace observer.")
        } catch {
            print("Failed to add workspace observer: \(error)")
        }
    }
    
    deinit {
        OSSystemExtensionsWorkspace.shared.removeObserver(self)
    }
    
    func queryExtensionProperties() {
        print("🔍 Initiating read-only properties query...")
        didFindActiveExtension = false // Reset state before checking
        
        let request = OSSystemExtensionRequest.propertiesRequest(
            forExtensionWithIdentifier: driverID,
            queue: DispatchQueue.main
        )
        request.delegate = self
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    func activate() {
        print("🚀 Requesting driver activation...")
        let request = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: driverID, queue: DispatchQueue.main)
        request.delegate = self
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        print("Request needs to replace the extension")
        return .replace
    }
    
    // MARK: - OSSystemExtensionRequestDelegate Callbacks
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("Request needs approval.")
        DispatchQueue.main.async {
            self.uiState = .waitingForUser
        }
    }
    
    // 💡 FIX HERE: This is where the properties query drops off its response!
    /*func request(_ request: OSSystemExtensionRequest, foundProperties properties: [OSSystemExtensionProperties]) {
        print("📊 Found properties array count: \(properties.count)")
        
        // Locate the property match for our driver bundle ID
        if let matchingProps = properties.first(where: { $0.bundleIdentifier == driverID }) {
            if matchingProps.isAwaitingUserApproval {
                self.uiState = .needsActivation
            } else if matchingProps.isUninstalling {
                self.uiState = .waitingForUser
            } else {
                self.uiState = matchingProps.isEnabled ? .enabled : .needsActivation
            }
        }
    }*/
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        print("🏁 Request cycle completed.")
        
        //queryExtensionProperties()
        
        DispatchQueue.main.async {
            switch result {
            case .completed:
                self.uiState = .enabled
            case .willCompleteAfterReboot:
                self.uiState = .needsActivation
            @unknown default:
                self.uiState = .checking
            }
        }
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: any Error) {
        let err = error as NSError
        print("Request failed. Domain: \(err.domain), Code: \(err.code)")
        
        DispatchQueue.main.async {
            self.uiState = .needsActivation
        }
    }
    
    // MARK: - OSSystemExtensionsWorkspaceObserver
    
    nonisolated func systemExtensionWillBecomeEnabled(_ info: OSSystemExtensionInfo) {
        guard info.bundleIdentifier == driverID else { return }
        print("Workspace Notification: Extension \(driverID) will become enabled.")
        
        Task { @MainActor in
            self.uiState = .enabled
        }
    }
    
    nonisolated func systemExtensionWillBecomeDisabled(_ info: OSSystemExtensionInfo) {
        guard info.bundleIdentifier == driverID else { return }
        print("Workspace Notification: Extension \(driverID) will become disabled.")
        
        Task { @MainActor in
            self.uiState = .needsActivation
        }
    }
    
    nonisolated func systemExtensionWillBecomeInactive(_ info: OSSystemExtensionInfo) {
        guard info.bundleIdentifier == driverID else { return }
        print("Workspace Notification: Extension \(driverID) will become inactive.")
        
        Task { @MainActor in
            self.uiState = .needsActivation
        }
    }
}
