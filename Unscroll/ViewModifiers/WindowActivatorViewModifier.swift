//
//  WindowActivatorViewModifier.swift
//  Unscroll
//
//  Created by Sebastian on 28/06/2026.
//

import SwiftUI

fileprivate struct WindowActivatorViewModifier<Value: Equatable>: ViewModifier {
    let windowIdentifier: String
    let value: Value
    let triggerValue: Value

    func body(content: Content) -> some View {
        content
            .onChange(of: value) {
                if value == triggerValue {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    NSApp.activate(ignoringOtherApps: true)

                    for window in NSApp.windows {
                        if let identifier = window.identifier,
                           identifier.rawValue == windowIdentifier {
                            window.makeKeyAndOrderFront(nil)
                            window.orderFrontRegardless()
                        }
                    }
                }
            }
    }
}

extension View {
    func activateWindow<Value: Equatable>(windowIdentifier: String, when value: Value, equals trigger: Value) -> some View {
        self.modifier(WindowActivatorViewModifier(windowIdentifier: windowIdentifier,value: value, triggerValue: trigger))
    }
}
