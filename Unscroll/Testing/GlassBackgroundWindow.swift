//
//  GlassV.swift
//  Unscroll
//
//  Created by Sebastian on 26/06/2026.
//

import AppKit
import SwiftUI

class GlassBackgroundWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 544, height: 704),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true

        let glassView = NSGlassEffectView()
        glassView.style = .regular
        glassView.tintColor = nil

        contentView = glassView
        
        setupSwiftUIContent(inside: glassView)
        
        center()
    }
    
    private func setupSwiftUIContent(inside glassView: NSGlassEffectView) {
        glassView.frame = NSRect(x: 0, y: 0, width: 544, height: 704)
        
        let hostingView = NSHostingView(rootView: WelcomeView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        glassView.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: glassView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: glassView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: glassView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: glassView.bottomAnchor)
        ])
    }
    
    func animatePopIn() {
        guard let contentView = self.contentView else { return }
        
        // 1. Tell AppKit this view uses Core Animation layers
        contentView.wantsLayer = true
        guard let layer = contentView.layer else { return }
        
        // 2. Set the anchor point to the center so it scales outward evenly
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Adjust the frame position because changing the anchor point shifts the view
        layer.frame = contentView.bounds
        
        // 3. Scale Animation (Starts slightly smaller, pops up to full size)
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [0.85, 1.03, 1.0] // Pop past 100% slightly, then settle
        scaleAnimation.keyTimes = [0.0, 0.7, 1.0]
        
        // 4. Fade-in Animation
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        
        // 5. Group them together
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, fadeAnimation]
        animationGroup.duration = 0.28 // Standard quick macOS animation duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // Apply it to the layer
        layer.add(animationGroup, forKey: "popInEffect")
    }
}
