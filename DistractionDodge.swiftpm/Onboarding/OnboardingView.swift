//
//  OnboardingView.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 21/01/25.
//

extension Timer: @unchecked @retroactive Sendable {}

import SwiftUI

/// A view that provides an interactive introduction.
///
/// The OnboardingView presents a series of educational pages about focus and attention,
/// incorporating interactive elements and animations to demonstrate key concepts.
/// It serves as the entry point for the experience, providing context about focus challenges
/// and introducing the app's training approach.
struct OnboardingView: View {
    // MARK: - Properties
    
    /// Current page index in the onboarding flow
    @State private var currentIndex = 0
    
    /// Scale factor for emoji animations
    @State private var emojiScale: CGFloat = 1
    
    /// Rotation angle for emoji animations
    @State private var emojiRotation: CGFloat = 0
    
    /// Scale factor for SF symbols
    @State private var symbolScale: CGFloat = 1
    
    /// Controls navigation state to prevent rapid transitions
    @State private var isNavigating = false
    
    /// Opacity level for background distractions
    @State private var distractionOpacity: Double = 0.3
    
    /// Controls the glow effect animation
    @State private var isGlowing = false
    
    /// Position of the interactive ball demonstration
    @State private var ballPosition = CGPoint(x: 100, y: UIScreen.main.bounds.height / 2)
    
    /// Timer for generating notifications in the demo
    @State private var notificationTimer: Timer?
    
    /// Collection of active notification demonstrations
    @State private var notifications: [(type: NotificationCategory, position: CGPoint, id: UUID)] = []
    
    /// Direction vector for ball movement
    @State private var moveDirection = CGPoint(x: 1, y: 1)
    
    /// Controls navigation to main content
    @State private var showContentView = false
    
    /// Controls navigation to tutorial
    @State private var showTutorial = false
    
    /// Tracks drag gesture state
    @GestureState private var dragOffset: CGFloat = 0
    
    let gradientColors: [(start: Color, end: Color)] = [
        (.black.opacity(0.8), .blue.opacity(0.2)),
        (.black.opacity(0.8), .indigo.opacity(0.2)),
        (.black.opacity(0.8), .purple.opacity(0.2)),
        (.black.opacity(0.8), .cyan.opacity(0.2)),
        (.black.opacity(0.8), .blue.opacity(0.25))
    ]
    
    let pages: [Page] = [
        Page(
            title: "Where Did Our Focus Go?",
            content: [
                "In today's fast-paced, page-filled world, our attention is constantly under attack.",
                "Notifications, social media, and endless multitasking leave us feeling scattered and overwhelmed.",
                "Research shows that fragmented attention isn't just exhausting, it makes it harder to think deeply, stay productive, and feel at peace."
            ],
            sfSymbol: "brain.head.profile.fill",
            emoji: "🧠",
            buttonText: "Tell me more"
        ),
        Page(
            title: "What Are Distractions Doing to Us?",
            content: [
                "Did you know the average person's focus shifts every 47 seconds while working?",
                "Frequent distractions reduce productivity by up to 40% and increase stress.",
                "Digital distractions train our brains to crave constant stimulation, making it harder to focus on what truly matters."
            ],
            sfSymbol: "clock.badge.exclamationmark.fill",
            emoji: "⏰",
            buttonText: "Is there a solution?"
        ),
        Page(
            title: "The Good News: You Can Retrain Your Brain",
            content: [
                "Focus isn't fixed, it's a skill you can strengthen with the right tools and practice.",
                "By training your brain to resist distractions, you can rebuild the deep focus needed to thrive in today's world."
            ],
            sfSymbol: "arrow.triangle.2.circlepath.circle.fill",
            emoji: "💪",
            buttonText: "How can I train?"
        ),
        Page(
            title: "How Distraction Dodge Helps You",
            content: [
                "Distraction Dodge is more than just a game, it's a tool to help you.",
                "Strengthen your focus through fun and engaging challenges.",
                "Learn to ignore digital distractions in a safe, controlled environment."
            ],
            sfSymbol: "target",
            emoji: "🔔",
            buttonText: "I'm ready"
        ),
        Page(
            title: "Take Control of Your Focus",
            content: [
                "It's time to start your journey toward a clearer, calmer, and more focused mind.",
                "Let's see how well you can dodge distractions and sharpen your attention skills."
            ],
            sfSymbol: "figure.mind.and.body",
            emoji: "🚀",
            buttonText: "Start Training"
        )
    ]
    
    private func navigate(forward: Bool) {
        if !isNavigating {
            isNavigating = true
            
            withAnimation {
                if forward && currentIndex < pages.count - 1 {
                    currentIndex += 1
                } else if !forward && currentIndex > 0 {
                    currentIndex -= 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNavigating = false
            }
        }
    }
    
    private func moveBallContinuously() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            Task { @MainActor in
                guard self.currentIndex == 3 else {
                    timer.invalidate()
                    return
                }
                
                let speed: CGFloat = 3.0
                let ballSize: CGFloat = 100
                let screenSize = UIScreen.main.bounds
                
                var newX = self.ballPosition.x + (self.moveDirection.x * speed)
                var newY = self.ballPosition.y + (self.moveDirection.y * speed)
                
                if newX <= ballSize/2 || newX >= screenSize.width - ballSize/2 {
                    self.moveDirection.x *= -1
                    newX = self.ballPosition.x + (self.moveDirection.x * speed)
                }
                if newY <= ballSize/2 || newY >= screenSize.height - ballSize/2 {
                    self.moveDirection.y *= -1
                    newY = self.ballPosition.y + (self.moveDirection.y * speed)
                }
                
                self.ballPosition = CGPoint(x: newX, y: newY)
            }
        }
    }
    
    private func generateNotifications() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            Task { @MainActor in
                guard self.currentIndex == 3 else {
                    timer.invalidate()
                    return
                }
                
                let topSafeArea: CGFloat = 100
                let bottomSafeArea: CGFloat = 120
                let sideSafeArea: CGFloat = 50
                
                let newNotification = (
                    type: NotificationCategory.allCases.randomElement()!,
                    position: CGPoint(
                        x: CGFloat.random(in: sideSafeArea...(UIScreen.main.bounds.width - sideSafeArea)),
                        y: CGFloat.random(in: topSafeArea...(UIScreen.main.bounds.height - bottomSafeArea))
                    ),
                    id: UUID()
                )
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.notifications.append(newNotification)
                    if self.notifications.count > 8 {
                        self.notifications.removeFirst()
                    }
                }
                
                let lifetime = Double.random(in: 3...6)
                DispatchQueue.main.asyncAfter(deadline: .now() + lifetime) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.notifications.removeAll { $0.id == newNotification.id }
                    }
                }
            }
        }
    }
    
    private func resetAndStartAnimations() {
        
        isGlowing = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever()) {
                self.isGlowing = true
            }
        }
        
        ballPosition = CGPoint(x: 100, y: UIScreen.main.bounds.height / 2)
        moveDirection = CGPoint(x: 1, y: 1)
        moveBallContinuously()
        generateNotifications()
    }
    
    @State private var activeLineIndex = 0
    @State private var completedLines: Set<Int> = []
    @State private var allLinesComplete = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        self.gradientColors[self.currentIndex].start,
                        self.gradientColors[self.currentIndex].end
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: self.currentIndex)
                
                if self.currentIndex == 3 {
                    ForEach(self.notifications, id: \.id) { notification in
                        Image(systemName: notification.type.rawValue)
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .position(notification.position)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.8)
                                        .combined(with: .opacity)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6)),
                                    removal: .scale(scale: 0.9)
                                        .combined(with: .opacity)
                                        .animation(.easeOut(duration: 0.5))
                                )
                            )
                    }
                }
                
                DistractionBackground()
                    .blur(radius: 20)
                
                if self.currentIndex == 3 {
                    MainCircle(isGazingAtTarget: self.isGlowing, position: self.ballPosition)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever()) {
                                self.isGlowing.toggle()
                            }
                            self.moveBallContinuously()
                            self.generateNotifications()
                        }
                }
                
                VStack {
                    
                    if self.currentIndex > 0 {
                        BackButtonView(isNavigating: self.isNavigating) {
                            self.navigate(forward: false)
                        }
                    }
                    
                    Spacer()
                    
                    OnboardingContentView(
                        page: self.pages[self.currentIndex],
                        currentIndex: self.currentIndex, activeLineIndex: $activeLineIndex,
                        completedLines: $completedLines,
                        allLinesComplete: $allLinesComplete,
                        
                        emojiScale: $emojiScale,
                        emojiRotation: $emojiRotation
                    )
                    
                    Spacer()
                    
                    NavigationButton(
                        buttonText: self.pages[self.currentIndex].buttonText,
                        allLinesComplete: self.allLinesComplete,
                        isLastScreen: self.currentIndex == self.pages.count - 1
                    ) {
                        if self.currentIndex == self.pages.count - 1 {
                            self.showTutorial = true
                        } else {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                self.navigate(forward: true)
                                self.activeLineIndex = 0
                                self.completedLines.removeAll()
                                self.allLinesComplete = false
                            }
                        }
                    }
                }
                .padding()
                
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold && !self.isNavigating {
                                self.navigate(forward: false)
                            } else if value.translation.width < -threshold && !self.isNavigating {
                                self.navigate(forward: true)
                            }
                        }
                )
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
        .onDisappear {
            
            self.notifications.removeAll()
        }
        .onChange(of: self.currentIndex) { _, _ in
            
            self.activeLineIndex = 0
            self.completedLines.removeAll()
            self.allLinesComplete = false
        }
    }
}
