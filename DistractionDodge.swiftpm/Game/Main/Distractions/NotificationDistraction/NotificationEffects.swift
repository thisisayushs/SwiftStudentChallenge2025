//
//  NotificationEffects.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 15/02/25.
//

import SwiftUI

/// A geometry effect that creates a horizontal shake animation.
///
/// This effect is used to draw attention to notifications by creating
/// a realistic shake motion with configurable intensity and frequency.
///
/// Usage:
/// ```swift
/// Text("Shake me")
///     .modifier(ShakeEffect(amount: 10, animatableData: 1))
/// ```
struct ShakeEffect: GeometryEffect {
    // MARK: - Properties
    
    /// Maximum shake displacement
    var amount: CGFloat = 10
    
    /// Number of shakes per animation cycle
    var shakesPerUnit = 3
    
    /// Current animation progress
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
                                                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                                              y: 0))
    }
}

/// A view modifier that creates a pulsing animation effect.
///
/// This modifier creates a subtle breathing effect by animating
/// the scale and opacity of content in a repeating pattern.
///
/// Usage:
/// ```swift
/// Image(systemName: "bell")
///     .modifier(PulseEffect())
/// ```
struct PulseEffect: ViewModifier {
    // MARK: - Properties
    
    /// Controls the animation state
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                    isAnimating = true
                }
            }
    }
}
