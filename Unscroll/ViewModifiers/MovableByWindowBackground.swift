//
//  MoveableWindowModifier.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import SwiftUI

fileprivate struct WindowAccessor: NSViewRepresentable {
    var onChange: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.onChange(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

fileprivate struct MoveableWindowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WindowAccessor { window in
                window?.isMovableByWindowBackground = true
            })
    }
}

extension View {
    func movableByWindowBackground() -> some View {
        self.modifier(MoveableWindowModifier())
    }
}
