//
//  VisualEffect.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

struct VisualEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar(removing: .title)
            .toolbarBackground(.hidden, for: .windowToolbar)
            .containerBackground(.thickMaterial, for: .window)
            .windowMinimizeBehavior(.disabled)
            .windowResizeBehavior(.disabled)
    }
}

extension View {
    func applyVisualEffect() -> some View {
        self.modifier(VisualEffectModifier())
    }
}
