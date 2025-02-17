//
//  DistractionBackground.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A view that creates an animated background with floating circles.
///
/// DistractionBackground provides:
/// - Randomly positioned translucent circles
/// - Gentle floating animation using HoverMotion
/// - Visual depth and movement to backgrounds
///
/// Usage:
/// ```swift
/// ZStack {
///     DistractionBackground()
///     // Your content
/// }
/// ```
struct DistractionBackground: View {
    // MARK: - Properties
    
    /// Controls the animation state of floating circles
    @State private var isAnimating = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Generate multiple floating circles
            ForEach(0...19, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 10...30))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .modifier(HoverMotion(isAnimating: isAnimating))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
