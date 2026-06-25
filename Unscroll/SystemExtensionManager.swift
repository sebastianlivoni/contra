//
//  SystemExtensionManager.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import SystemExtensions

class SystemExtensionManager: NSObject, OSSystemExtensionRequestDelegate {
    let driverID = "me.livoni.Unscroll.UnscrollDriver"
    
    func activate() {
        let request = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: driverID, queue: DispatchQueue.main)
        request.delegate = self
        let extensionManager = OSSystemExtensionManager.shared
        extensionManager.submitRequest(request)
    }
    
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        print("Request needs to replace the extension")
        
        return .replace
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("Request needs approval.")
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        print("Request finished successfully")
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: any Error) {
        let err = error as NSError
        print("Request failed.")
        print("  Domain: \(err.domain)")
        print("  Code: \(err.code)")
        print("  UserInfo: \(err.userInfo)")
        
        if err.domain == OSSystemExtensionErrorDomain,
               let code = OSSystemExtensionError.Code(rawValue: err.code) {
                switch code {
                case .unknown:                      print("  Meaning: unknown")
                case .missingEntitlement:           print("  Meaning: missingEntitlement")
                case .unsupportedParentBundleLocation: print("  Meaning: unsupportedParentBundleLocation")
                case .extensionNotFound:            print("  Meaning: extensionNotFound")
                case .extensionMissingIdentifier:   print("  Meaning: extensionMissingIdentifier")
                case .duplicateExtensionIdentifer:  print("  Meaning: duplicateExtensionIdentifier")
                case .unknownExtensionCategory:     print("  Meaning: unknownExtensionCategory")
                case .codeSignatureInvalid:         print("  Meaning: codeSignatureInvalid")
                case .validationFailed:             print("  Meaning: validationFailed")
                case .forbiddenBySystemPolicy:      print("  Meaning: forbiddenBySystemPolicy")
                case .requestCanceled:              print("  Meaning: requestCanceled")
                case .requestSuperseded:            print("  Meaning: requestSuperseded")
                case .authorizationRequired:        print("  Meaning: authorizationRequired")
                @unknown default:                   print("  Meaning: unrecognized \(err.code)")
                }
            }
    
        // Also check system log for more detail
    }
}
