//
//  TextAnimator.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 22/01/25.
//

import SwiftUI
import AVFoundation

/// A view that creates a typewriter-like text animation effect with sound feedback.
///
/// This component animates text by displaying it character by character, creating
/// a typing machine effect. It includes keyboard sound effects and manages the timing
/// of text display through a configurable interval.
struct TextAnimator: View {
    /// The text content to be animated
    let text: String
    /// The sequential position of this animator in a series of animations
    let index: Int
    /// Binding to track which text block should currently be animating
    @Binding var activeIndex: Int
    /// The text that is currently being displayed during animation
    @State private var displayedText = ""
    /// Timer that controls the typing animation
    @State private var timer: Timer? = nil
    /// Callback executed when the typing animation completes
    var onFinished: () -> Void
    /// The time interval between displaying each character
    private let typingInterval: TimeInterval = 0.05
    /// The delay before playing the typing sound effect
    private let soundDelay: TimeInterval = 0.02
    
    /// Actor to manage the animation
    private actor AnimationState {
        var charIndex: Int = 0
        
        func incrementIndex() async -> Int {
            try? await Task.sleep(nanoseconds: 1)
            charIndex += 1
            return charIndex
        }
        
        func reset() async {
            try? await Task.sleep(nanoseconds: 1)
            charIndex = 0
        }
        
        func isLessThanCount(_ count: Int) async -> Bool {
            try? await Task.sleep(nanoseconds: 1)
            return charIndex < count
        }
        
        func getCurrentTextSegment(text: String) async -> (String, String) {
            try? await Task.sleep(nanoseconds: 1)
            let textIndex = text.index(text.startIndex, offsetBy: charIndex)
            let currentChar = String(text[textIndex])
            let displayText = String(text[...textIndex])
            return (currentChar, displayText)
        }
    }
    
    @State private var animationState = AnimationState()
    
    var body: some View {
        HStack {
            
            Text(displayedText)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            
            if index == activeIndex {
                startTyping()
                
            }
        }
        .onChange(of: activeIndex) { _, newValue in
            
            if index == newValue {
                startTyping()
            }
        }
        .onDisappear {
            
            timer?.invalidate()
            timer = nil
        }
    }
    
    /// Initiates the typing animation sequence
    ///
    /// This method handles the character-by-character display of text,
    /// playing sound effects for each character except punctuation and spaces.
    /// When animation completes, it triggers the onFinished callback.
    private func startTyping() {
        
        displayedText = ""
        timer?.invalidate()
        
        Task {
            await animationState.reset()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { timer in
            Task {
                guard await animationState.isLessThanCount(self.text.count) else {
                    timer.invalidate()
                    await MainActor.run {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.onFinished()
                        }
                    }
                    return
                }
                
                let (currentChar, displayText) = await animationState.getCurrentTextSegment(text: self.text)
                
                await MainActor.run {
                    self.displayedText = displayText
                }
                
                let _ = await animationState.incrementIndex()
                
                if !["", " ", ".", ",", "!", "?"].contains(currentChar) {
                    await MainActor.run {
                        DispatchQueue.main.asyncAfter(deadline: .now() + soundDelay) {
                            AudioServicesPlaySystemSound(1104)
                        }
                    }
                }
            }
        }
    }
}
