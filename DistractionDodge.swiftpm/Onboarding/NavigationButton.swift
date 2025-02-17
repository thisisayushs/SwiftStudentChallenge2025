//
//  NavigationButton.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 10/02/25.
//

import SwiftUI

/// A custom navigation button used in the onboarding flow that provides visual feedback based on completion state.
///
/// The button's appearance and interactivity changes based on whether all required actions are completed
/// and whether it's the last screen in the sequence. It features dynamic animations and styling.
struct NavigationButton: View {
    /// The text to display on the button
    let buttonText: String
    
    /// Indicates whether all required lines are completed
    ///
    /// When true, the button becomes fully interactive and displays a pulsing animation
    let allLinesComplete: Bool
    
    /// Indicates if this button appears on the last screen of the sequence
    let isLastScreen: Bool
    
    /// The action to perform when the button is tapped
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(buttonText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 35)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .overlay(Capsule().stroke(Color.white, lineWidth: 1.5))
                    .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            
            .scaleEffect(allLinesComplete ? 1.1 : 1.0)
            
            .animation(allLinesComplete ?
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true) :
                    .easeInOut(duration: 0.3),
                       value: allLinesComplete
            )
        }
        .opacity(allLinesComplete ? 1 : 0.5)
        .disabled(!allLinesComplete)
        .padding(.bottom, 40)
    }
}
