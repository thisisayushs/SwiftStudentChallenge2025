//
//  MainCircle.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 28/12/24.
//

import SwiftUI

/// A view representing the main focus target in the game.
///
/// MainCircle provides visual feedback about the player's focus through:
/// - Color changes based on gaze status
/// - Scale animations when focused
/// - Gradient and glow effects
///
/// Usage:
/// ```swift
/// MainCircle(
///     isGazingAtTarget: isGazing,
///     position: targetPosition
/// )
/// ```
struct MainCircle: View {
    // MARK: - Properties
    
    /// Indicates whether the player is currently looking at the target
    let isGazingAtTarget: Bool
    
    /// Current position of the circle on screen
    let position: CGPoint
    
    // MARK: - Body
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: isGazingAtTarget ?
                                       [.green, .mint] : [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 200, height: 200)
            .scaleEffect(isGazingAtTarget ? 1.2 : 1.0)
            .shadow(color: isGazingAtTarget ? .green.opacity(0.5) : .blue.opacity(0.5),
                    radius: isGazingAtTarget ? 15 : 10)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
            .position(x: position.x, y: position.y)
            .animation(.easeInOut(duration: 2), value: position)
            .animation(.easeInOut(duration: 0.3), value: isGazingAtTarget)
    }
}
