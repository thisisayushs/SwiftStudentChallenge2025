//
//  GameObstructionView.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 15/02/25.
//

import SwiftUI

/// A view that appears when the player loses focus by interacting with a distraction.
///
/// This view provides feedback about the game ending due to distraction and offers
/// the option to restart the game. It features:
/// - Visual warning with animated icon
/// - Explanation of why the game ended
/// - Option to restart the game
///
/// Usage:
/// ```swift
/// GameObstructionView(
///     viewModel: attentionViewModel,
///     isPresented: $showGameOver
/// )
/// ```
struct GameObstructionView: View {
    @ObservedObject var viewModel: AttentionViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.red.opacity(0.8), .orange.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 35) {
                VStack(spacing: 25) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .padding(.bottom)
                    
                    VStack(spacing: 15) {
                        Text("Attention Lost!")
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("You got distracted and tapped on a distraction object.")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.white.opacity(0.15))
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 15)
                    )
                }
                
                Button {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.startGame()
                    }
                } label: {
                    Text("Try Again")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10)
                }
                .padding(.top, 20)
            }
            .padding(40)
        }
        .presentationBackground(.clear)
        .presentationCornerRadius(35)
        
    }
}
