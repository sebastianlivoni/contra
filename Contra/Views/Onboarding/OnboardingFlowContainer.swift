//
//  OnboardingFlowContainer.swift
//  Contra
//
//  Created by Sebastian on 28/06/2026.
//
import SwiftUI

struct OnboardingFlowContainer: View {
    @AppStorage("onboardingProgress") private var persistentProgress: OnboardingProgress = .welcome
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding: Bool = false

    @State private var sessionProgress: OnboardingProgress = .welcome

    var body: some View {
        VStack {
            switch sessionProgress {
            case .welcome:
                WelcomeView(progress: $sessionProgress)
                    .id(OnboardingProgress.welcome)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .dextDriver:
                DextDriverView(progress: $sessionProgress)
                    .id(OnboardingProgress.dextDriver)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .safariExtension:
                SafariExtensionView(progress: $sessionProgress)
                    .id(OnboardingProgress.safariExtension)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .completed:
                Color.clear
                    .onAppear {
                        setSessionProgress(.welcome, animated: false)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: sessionProgress)
        .frame(width: 540, height: 650)
        .clipped()
        .onAppear {
            if !hasShownOnboarding {
                setSessionProgress(persistentProgress, animated: false)
            } else {
                setSessionProgress(.welcome, animated: false)
            }
        }
        .onChange(of: sessionProgress) { _, newValue in
            if !hasShownOnboarding {
                persistentProgress = newValue
            }
        }
    }

    private func setSessionProgress(_ newValue: OnboardingProgress, animated: Bool) {
        if animated {
            sessionProgress = newValue
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                sessionProgress = newValue
            }
        }
    }
}

#Preview {
    OnboardingFlowContainer()
}
