//
//  ConclusionView.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 22/01/25.
//

import SwiftUI

/// A view that presents the user's performance results and feedback after completing a focus training session.
///
/// ConclusionView provides:
/// - Animated score reveal
/// - Performance statistics display
/// - Contextual tips based on performance
/// - Options to retry or restart training
struct ConclusionView: View {
    // MARK: - Properties
    
    /// View model containing game results and statistics
    @ObservedObject var viewModel: AttentionViewModel
    
    /// Environment dismiss action
    @Environment(\.dismiss) var dismiss
    
    /// Tracks completion of introduction for navigation
    @AppStorage("hasCompletedIntroduction") private var hasCompletedIntroduction = false
    
    /// Animated score counter
    @State private var displayedScore = 0
    
    /// Controls navigation back to introduction
    @State private var showRestartIntroduction = false
    
    /// Scale factor for score animation
    @State private var scoreScale: CGFloat = 0.5
    
    /// Controls animation states
    @State private var isAnimating = false
    
    /// Scale factor for button animations
    @State private var buttonScale: CGFloat = 1.0
    
    /// Triggers button animation after score reveal
    @State private var shouldAnimateButton = false
    
    /// Background gradient colors
    private let gradientColors: [Color] = [
        .black.opacity(0.8),
        .purple.opacity(0.25)
    ]
    
    /// Provides contextual tips based on the user's score
    private var focusTips: String {
        if viewModel.score < 20 {
            return "Try to maintain your gaze on the target consistently. Small improvements in focus can lead to better scores."
        } else if viewModel.score < 40 {
            return "Your focus is improving! Try to build longer streaks by staying locked on the target."
        } else {
            return "Excellent focus control! Keep challenging yourself to maintain even longer streaks."
        }
    }
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            
            DistractionBackground()
                .blur(radius: 20)
            
            VStack(spacing: 45) {
                
                VStack(spacing: 30) {
                    Text("Focus Score")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("\(displayedScore)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(scoreScale)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.1), value: scoreScale)
                        .onAppear {
                            
                            displayedScore = 0
                            scoreScale = 0.5
                            isAnimating = false
                            shouldAnimateButton = false
                            
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.5)) {
                                scoreScale = 1.0
                            }
                            
                            let finalScore = viewModel.score
                            let animationDuration: TimeInterval = 1.5
                            
                            let _ = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
                                Task { @MainActor in
                                    if displayedScore < finalScore {
                                        displayedScore += 1
                                        
                                        if displayedScore % 10 == 0 {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                                scoreScale = 1.1
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                                    scoreScale = 1.0
                                                }
                                            }
                                        }
                                    } else {
                                        timer.invalidate()
                                        
                                        shouldAnimateButton = true
                                    }
                                }
                                
                                if finalScore > 0 {
                                    timer.tolerance = animationDuration / Double(finalScore)
                                }
                            }
                        }
                    
                    Text(focusTips)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.15))
                        )
                    
                    HStack(spacing: 20) {
                        StatCard(title: "Total Focus",
                                 value: "\(Int(viewModel.totalFocusTime))s",
                                 icon: "clock.fill")
                        
                        StatCard(title: "Best Streak",
                                 value: "\(Int(viewModel.bestStreak))s",
                                 icon: "bolt.fill")
                    }
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    Button {
                        viewModel.startGame()
                        dismiss()
                    } label: {
                        HStack {
                            Text("Try Again")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 35)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 1.5)
                                )
                                .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: 2)
                        )
                    }
                    .scaleEffect(buttonScale)
                    .onChange(of: shouldAnimateButton) { _, newValue in
                        if newValue {
                            withAnimation(
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                            ) {
                                buttonScale = 1.1
                            }
                        }
                    }
                    
                    Button {
                        hasCompletedIntroduction = false
                        showRestartIntroduction = true
                    } label: {
                        HStack {
                            Text("Start Over")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 35)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                                .shadow(color: .white.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(30)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        
        .fullScreenCover(isPresented: $showRestartIntroduction) {
            OnboardingView()
        }
    }
}
