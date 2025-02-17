//
//  PauseMenuView.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 22/01/25.
//

import SwiftUI

/// A view that displays the pause menu during gameplay.
///
/// PauseMenuView provides options to:
/// - Resume the current game
/// - Restart the game
/// - Return to introduction
///
/// Usage:
/// ```swift
/// PauseMenuView(viewModel: attentionViewModel)
/// ```
struct PauseMenuView: View {
    // MARK: - Properties
    
    /// View model containing game state and control methods
    @ObservedObject var viewModel: AttentionViewModel
    
    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss
    
    /// Controls navigation to introduction screen
    @State private var showIntroduction = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .purple.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 35) {
                Text("Game Paused")
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    Button {
                        dismiss()
                        viewModel.resumeGame()
                    } label: {
                        MenuButton(title: "Resume", icon: "play.fill")
                    }
                    
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.startGame()
                        }
                    } label: {
                        MenuButton(title: "Restart", icon: "arrow.clockwise")
                    }
                    
                    Button {
                        showIntroduction = true
                    } label: {
                        MenuButton(title: "Start Over", icon: "arrow.left")
                    }
                }
            }
            .padding(40)
        }
        .presentationBackground(.clear)
        .presentationCornerRadius(35)
        .interactiveDismissDisabled()
        .fullScreenCover(isPresented: $showIntroduction) {
            OnboardingView()
        }
    }
}

/// A styled button view used in the pause menu.
///
/// MenuButton provides a consistent style for pause menu options with:
/// - Icon and text combination
/// - Translucent background
/// - Border and shadow effects
struct MenuButton: View {
    // MARK: - Properties
    
    /// Title text for the button
    let title: String
    
    /// SF Symbol name for the button icon
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.system(.title3, design: .rounded))
                .bold()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
    }
}
