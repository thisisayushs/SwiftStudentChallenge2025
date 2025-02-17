//
//  HoverMotion.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A view modifier that adds a floating animation effect to content.
///
/// This modifier creates a gentle hovering motion by randomly offsetting the content
/// vertically with a smooth, repeating animation. It's used to create engaging
/// visual effects in the onboarding experience.
///
/// Usage:
/// ```swift
/// Text("Floating Text")
///     .modifier(HoverMotion(isAnimating: true))
/// ```
struct HoverMotion: ViewModifier {
    // MARK: - Properties
    
    /// Controls whether the hover animation is active
    let isAnimating: Bool
    
    /// Applies the hover motion effect to the content
    /// - Parameter content: The view to be modified
    /// - Returns: The modified view with hover animation
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? CGFloat.random(in: -20...20) : 0)
            .animation(
                Animation.easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
    }
}
