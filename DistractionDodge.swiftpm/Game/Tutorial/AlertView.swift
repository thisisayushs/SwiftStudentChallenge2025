//
// AlertView.swift
// DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A custom alert view component used throughout the tutorial.
///
/// AlertView provides a styled alert dialog with:
/// - Title and message
/// - Primary and secondary actions
/// - Animated presentation
/// - Dismissible background
///
/// Usage:
/// ```swift
/// AlertView(
///     title: "Skip Tutorial?",
///     message: "You are about to skip the tutorial.",
///     primaryAction: { /* handle primary action */ },
///     secondaryAction: { /* handle secondary action */ },
///     isPresented: $showAlert
/// )
/// ```
struct AlertView: View {
    // MARK: - Properties
    
    /// Title displayed at the top of the alert
    let title: String
    
    /// Message text explaining the alert
    let message: String
    
    /// Closure executed when primary action is taken
    let primaryAction: () -> Void
    
    /// Closure executed when secondary action is taken
    let secondaryAction: () -> Void
    
    /// Binding to control alert presentation
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.easeOut) {
                        isPresented = false
                    }
                }
            
            
            VStack(spacing: 25) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    
                    Button(action: {
                        withAnimation(.easeOut) {
                            isPresented = false
                            secondaryAction()
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    
                    Button(action: {
                        withAnimation(.easeOut) {
                            isPresented = false
                            primaryAction()
                        }
                    }) {
                        Text("Skip")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 35)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.red.opacity(0.8), .orange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.5))
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Material.ultraThinMaterial)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 15)
            )
            .padding(30)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}
