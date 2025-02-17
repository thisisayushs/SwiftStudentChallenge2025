//
//  GlassBackground.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 15/02/25.
//

import SwiftUI

/// A view that creates a translucent glass-like background effect.
///
/// GlassBackground combines multiple layers to create a frosted glass appearance:
/// - Base translucent white layer
/// - Blurred overlay
/// - Gradient shine effect
///
/// Usage:
/// ```swift
/// SomeView()
///     .background(GlassBackground())
/// ```
struct GlassBackground: View {
    var body: some View {
        ZStack {
            // Base translucent layer
            Color.white.opacity(0.15)
            
            
            // Blurred overlay for depth
            Rectangle()
                .fill(Color.white)
                .opacity(0.05)
                .blur(radius: 10)
            
            
            // Gradient shine effect
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
