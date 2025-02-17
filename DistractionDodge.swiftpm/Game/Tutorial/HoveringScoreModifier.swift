//
//  HoveringScoreModifier.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A view modifier that creates a floating animation effect for score indicators.
///
/// FloatingScoreModifier animates content with:
/// - Scale animation
/// - Upward floating motion
/// - Fade in/out effect
///
/// Usage:
/// ```swift
/// Text("+1")
///     .modifier(FloatingScoreModifier(isShowing: true))
/// ```
struct FloatingScoreModifier: ViewModifier {
    // MARK: - Properties
    
    /// Controls visibility and animation state
    let isShowing: Bool
    
    /// Applies the floating animation to the content
    /// - Parameter content: The view to be modified
    /// - Returns: The modified view with floating animation
    func body(content: Content) -> some View {
        content
            .opacity(isShowing ? 1 : 0)
            .scaleEffect(isShowing ? 1.2 : 0.8)
            .offset(y: isShowing ? -50 : 0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .speed(0.7),
                value: isShowing
            )
    }
}
