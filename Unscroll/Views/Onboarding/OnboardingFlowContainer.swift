//
//  OnboardingFlowContainer.swift
//  Unscroll
//
//  Created by Sebastian on 28/06/2026.
//

import SwiftUI

struct OnboardingFlowContainer: View {
    @AppStorage("onboardingProgress") private var persistentProgress: OnboardingProgress = .welcome
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding: Bool = false
    
    // In-memory state used for manual re-runs
    @State private var sessionProgress: OnboardingProgress = .welcome

    var body: some View {
        VStack {
            switch sessionProgress {
            case .welcome:
                WelcomeView(progress: $sessionProgress)
            case .dextDriver:
                DextDriverView(progress: $sessionProgress)
            case .safariExtension:
                SafariExtensionView(progress: $sessionProgress)
            case .completed:
                Color.clear.onAppear {
                    // Reset session in case they open it yet again later
                    sessionProgress = .welcome
                }
            }
        }
        .frame(width: 540, height: 650)
        .onAppear {
            // If they haven't finished onboarding before, sync with AppStorage.
            // If they HAVE finished before, always start them at .welcome for this session.
            if !hasShownOnboarding {
                sessionProgress = persistentProgress
            } else {
                sessionProgress = .welcome
            }
        }
        // Mirror changes back to AppStorage ONLY during the first-time onboarding
        .onChange(of: sessionProgress) { _, newValue in
            if !hasShownOnboarding {
                persistentProgress = newValue
            }
        }
    }
}
