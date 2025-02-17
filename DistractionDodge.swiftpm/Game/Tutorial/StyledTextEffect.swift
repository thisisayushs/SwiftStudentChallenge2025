//
//  StyledTextEffect.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A view modifier that applies animated effects to bonus and penalty text.
///
/// StyledTextEffect provides different animation styles for:
/// - Bonus score announcements (upward motion)
/// - Penalty notifications (downward motion)
/// - Scale, rotation, and blur effects
///
/// Usage:
/// ```swift
/// Text("+5 BONUS")
///     .modifier(StyledTextEffect(isShowing: true, style: .bonus))
/// ```
struct StyledTextEffect: ViewModifier {
    // MARK: - Properties
    
    /// Controls visibility and animation state
    let isShowing: Bool
    
    /// Determines the animation style (bonus or penalty)
    let style: TextStyle
    
    /// Defines different text animation styles
    enum TextStyle {
        /// Upward, positive animation for bonuses
        case bonus
        /// Downward, negative animation for penalties
        case penalty
    }
    
    /// Applies the styled animation to the content
    /// - Parameter content: The view to be modified
    /// - Returns: The modified view with animation effects
    func body(content: Content) -> some View {
        content
            .opacity(isShowing ? 1 : 0)
            .scaleEffect(isShowing ? 1 : 0.8)
            .rotationEffect(.degrees(isShowing ? 0 : style == .bonus ? -10 : 10))
            .offset(y: isShowing ? 0 : style == .bonus ? 20 : -20)
            .blur(radius: isShowing ? 0 : 5)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .speed(0.8),
                value: isShowing
            )
    }
}
