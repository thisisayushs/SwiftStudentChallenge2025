//
//  VideoDistraction.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 22/01/25.
//

import SwiftUI

/// A view that simulates a social media video feed as a distraction element.
///
/// VideoDistraction provides an engaging distraction through:
/// - Scrollable video content
/// - Floating emojis and symbols
/// - Interactive animations
/// - Gradient backgrounds
///
/// Usage:
/// ```swift
/// VideoDistraction()
///     .environmentObject(attentionViewModel)
/// ```
struct VideoDistraction: View {
    // MARK: - Properties
    
    /// View model for game state and control
    @EnvironmentObject var viewModel: AttentionViewModel
    
    /// Vertical offset for floating animation
    @State private var offset: CGFloat = 0
    
    /// Current video index
    @State private var currentIndex = 0
    
    /// Collection of animated floating elements
    @State private var floatingElements: [FloatingElement] = []
    
    /// Gesture translation state
    @GestureState private var translation: CGFloat = 0
    
    /// Sample video content
    let videos = [
        VideoContent(
            title: "Amazing Dance Moves! 🔥",
            username: "@dancepro",
            description: "Check out these incredible moves! #dance #viral",
            gradientColors: [.purple, .pink],
            emojis: ["💃", "🕺", "🎵", "✨"],
            symbols: ["flame.fill", "star.fill", "bolt.fill"]
        ),
        VideoContent(
            title: "Funny Cat Compilation 😹",
            username: "@catvideos",
            description: "You won't believe what these cats did! #cats #funny",
            gradientColors: [.blue, .green],
            emojis: ["😹", "🐱", "🙀", "🎭"],
            symbols: ["pawprint.fill", "heart.fill", "face.smiling"]
        ),
        VideoContent(
            title: "Epic Stunts! 💪",
            username: "@extremesports",
            description: "Don't try this at home! #extreme #sports",
            gradientColors: [.orange, .red],
            emojis: ["🏄‍♂️", "🚴‍♀️", "🏂", "🤸‍♂️"],
            symbols: ["speedometer", "flag.fill", "trophy.fill"]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: videos[currentIndex].gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.8)
                .animation(.easeInOut(duration: 1.0), value: currentIndex)
                
                
                ZStack {
                    ForEach(floatingElements) { element in
                        if element.content.first?.isEmoji ?? false {
                            Text(element.content)
                                .font(.system(size: 35))
                                .position(element.position)
                                .scaleEffect(element.scale)
                                .rotationEffect(.degrees(element.rotation))
                        } else {
                            Image(systemName: element.content)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .position(element.position)
                                .scaleEffect(element.scale)
                                .rotationEffect(.degrees(element.rotation))
                        }
                    }
                }
                .clipped()
                
                VStack(alignment: .leading, spacing: 15) {
                    Spacer()
                    
                    
                    Text(videos[currentIndex].title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding(.horizontal, 10)
                    
                    
                    Text(videos[currentIndex].username)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                    
                    
                    Text(videos[currentIndex].description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    
                    
                    HStack(spacing: 20) {
                        ForEach(["heart.fill", "message.fill", "arrow.2.squarepath"], id: \.self) { symbolName in
                            Image(systemName: symbolName)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.6)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let threshold = geometry.size.height * 0.25
                        if abs(value.translation.height) > threshold {
                            withAnimation {
                                currentIndex = value.translation.height > 0 ?
                                (currentIndex - 1 + videos.count) % videos.count :
                                (currentIndex + 1) % videos.count
                                resetFloatingElements(width: geometry.size.width, height: geometry.size.height)
                                
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    viewModel.handleDistractionTap()
                                }
                            }
                        }
                    }
            )
            .onTapGesture {
                viewModel.handleDistractionTap()
            }
            .onAppear {
                startAnimations(in: geometry)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    resetFloatingElements(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .onDisappear {
                
                invalidateTimers()
            }
        }
    }
    
    // Add timer properties
    @State private var contentTimer: Timer?
    @State private var animationTimer: Timer?
    
    private func invalidateTimers() {
        contentTimer?.invalidate()
        animationTimer?.invalidate()
        contentTimer = nil
        animationTimer = nil
    }
    
    private func startAnimations(in geometry: GeometryProxy) {
        let width = geometry.size.width
        let height = geometry.size.height
        
        
        withAnimation(
            Animation
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            offset = 30
        }
        
        
        invalidateTimers()
        contentTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                withAnimation {
                    currentIndex = (currentIndex + 1) % videos.count
                    resetFloatingElements(width: width, height: height)
                }
            }
        }
        
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.016)) {
                    updateFloatingElements(height: height, width: width)
                }
            }
        }
    }
    
    private func resetFloatingElements(width: CGFloat, height: CGFloat) {
        let currentVideo = videos[currentIndex]
        let elements = (currentVideo.emojis + currentVideo.symbols)
        
        
        let minimumElements = 12
        let repeatedElements = elements.count < minimumElements ?
        elements + elements + elements : elements
        
        floatingElements = repeatedElements.map { content in
            FloatingElement(
                position: CGPoint(
                    x: CGFloat.random(in: 0...width),
                    y: CGFloat.random(in: 0...height)
                ),
                scale: CGFloat.random(in: 1.0...1.8),
                rotation: Double.random(in: 0...360),
                content: content,
                velocity: CGPoint(
                    x: CGFloat.random(in: -2...2),
                    y: CGFloat.random(in: -3...0)
                )
            )
        }
    }
    
    private func updateFloatingElements(height: CGFloat, width: CGFloat) {
        let dampening: CGFloat = 0.98
        let maxSpeed: CGFloat = 5.0
        
        for i in floatingElements.indices {
            
            floatingElements[i].velocity.x += CGFloat.random(in: -0.5...0.5)
            floatingElements[i].velocity.y += CGFloat.random(in: -0.5...0.3)
            
            
            floatingElements[i].velocity.x *= dampening
            floatingElements[i].velocity.y *= dampening
            
            
            floatingElements[i].velocity.x = floatingElements[i].velocity.x.clamped(to: -maxSpeed...maxSpeed)
            floatingElements[i].velocity.y = floatingElements[i].velocity.y.clamped(to: -maxSpeed...maxSpeed)
            
            
            floatingElements[i].position.x += floatingElements[i].velocity.x
            floatingElements[i].position.y += floatingElements[i].velocity.y
            
            
            let rotationSpeed = abs(floatingElements[i].velocity.x) + abs(floatingElements[i].velocity.y)
            floatingElements[i].rotation += Double(rotationSpeed * 2.0)
            
            
            let time = Date().timeIntervalSince1970
            let breathingScale = sin(time * 2 + Double(i)) * 0.2
            floatingElements[i].scale = (1.4 + breathingScale).clamped(to: 0.8...2.0)
            
            
            if floatingElements[i].position.x < -50 {
                floatingElements[i].position.x = width + 50
            } else if floatingElements[i].position.x > width + 50 {
                floatingElements[i].position.x = -50
            }
            
            if floatingElements[i].position.y < -50 {
                floatingElements[i].position.y = height + 50
            } else if floatingElements[i].position.y > height + 50 {
                floatingElements[i].position.y = -50
            }
        }
    }
}

// MARK: - Helper Extensions

/// Extends Character to check for emoji properties
extension Character {
    var isEmoji: Bool {
        guard let scalar = UnicodeScalar(String(self)) else { return false }
        return scalar.properties.isEmoji
    }
}

/// Extends String to check if it contains only an emoji
extension String {
    var isEmoji: Bool {
        count == 1 && first?.isEmoji == true
    }
}

/// Extends Comparable to add value clamping functionality
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
