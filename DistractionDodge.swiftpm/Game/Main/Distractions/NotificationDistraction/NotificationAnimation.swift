//
//  NotificationAnimation.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 15/02/25.
//

import SwiftUI

/// A view modifier that adds shake animation to notification distractions.
///
/// This modifier creates a spring-based shake effect for notifications to catch
/// the user's attention, with configurable delay based on notification index.
///
/// Usage:
/// ```swift
/// Text("Notification")
///     .modifier(NotificationAnimation(index: 0))
/// ```
struct NotificationAnimation: ViewModifier {
    // MARK: - Properties
    
    /// Index of the notification, used for staggered animation timing
    let index: Int
    
    /// Controls the shake animation state
    @State private var shake = false
    
    /// Applies shake animation to the content
    /// - Parameter content: The view to be modified
    /// - Returns: The modified view with shake animation
    func body(content: Content) -> some View {
        content
            .offset(y: -20)
            .modifier(ShakeEffect(amount: shake ? 5 : 0, animatableData: shake ? 1 : 0))
            .animation(
                .spring(response: 0.5, dampingFraction: 0.65)
                .delay(Double(index) * 0.15),
                value: index
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatCount(3, autoreverses: true)
                ) {
                    shake = true
                }
            }
    }
}
