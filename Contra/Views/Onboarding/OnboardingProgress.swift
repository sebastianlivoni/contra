//
//  OnboardingProgress.swift
//  Contra
//
//  Created by Sebastian on 28/06/2026.
//

import Foundation

enum OnboardingProgress: String, Codable, CaseIterable {
    case welcome
    case dextDriver
    case safariExtension
    case completed
}
