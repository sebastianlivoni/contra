//
//  VisualEffect.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

fileprivate struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSGlassEffectView {
        let effectView = NSGlassEffectView()
        effectView.style = .regular
        return effectView
    }

    func updateNSView(_ nsView: NSGlassEffectView, context: Context) {
    }
}

fileprivate struct VisualEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(VisualEffectView().ignoresSafeArea())
    }
}

extension View {
    func applyVisualEffect() -> some View {
        self.modifier(VisualEffectModifier())
    }
}
