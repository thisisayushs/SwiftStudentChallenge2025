//
//  AttentionViewModel.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 28/12/24.
//

import SwiftUI
import AVFoundation

/// The view model responsible for managing the focus training game's state and logic.
///
/// AttentionViewModel handles:
/// - Game state management (start, pause, resume, stop)
/// - Score tracking and calculations
/// - Focus streak monitoring
/// - Distraction generation and management
/// - Target movement patterns
/// - Eye gaze status updates
///
/// Usage:
/// ```swift
/// @StateObject private var viewModel = AttentionViewModel()
/// ```
@MainActor class AttentionViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current position of the focus target
    @Published var position = CGPoint(x: UIScreen.main.bounds.width / 2,
                                      y: UIScreen.main.bounds.height / 2)
    
    /// Indicates if the user is currently gazing at the target
    @Published var isGazingAtObject = false
    
    /// Collection of active distractions
    @Published var distractions: [Distraction] = []
    
    /// Current game score
    @Published var score: Int = 0
    
    /// Duration of current focus streak
    @Published var focusStreak: TimeInterval = 0
    
    /// Longest focus streak achieved
    @Published var bestStreak: TimeInterval = 0
    
    /// Total time spent focused during the game
    @Published var totalFocusTime: TimeInterval = 0
    
    /// Remaining game time in seconds
    @Published var gameTime: TimeInterval = 60
    
    /// Indicates if the game is currently active
    @Published var gameActive = false
    
    /// Current background gradient colors
    @Published var backgroundGradient: [Color] = [.black.opacity(0.8), .cyan.opacity(0.2)]
    
    /// Reason for game ending (time up or distraction)
    @Published var endGameReason: EndGameReason = .timeUp
    
    /// Indicates if the game is paused
    @Published var isPaused = false
    
    enum EndGameReason {
        case timeUp
        case distractionTap
    }
    
    private var timer: Timer?
    private var distractionTimer: Timer?
    private var focusStreakTimer: Timer?
    private var gameTimer: Timer?
    private var wasActiveBeforeBackground = false
    private var isInBackground = false
    private var moveDirection = CGPoint(x: 1, y: 1)
    private var currentNotificationInterval: TimeInterval = 2.0
    private var distractionProbability: Double = 0.2
    private var scoreMultiplier: Int = 1
    private var lastFocusState: Bool = false
    
    let notificationData: [(title: String, icon: String, colors: [Color], sound: SystemSoundID)] = [
        ("Messages", "message.fill",
         [Color(red: 32/255, green: 206/255, blue: 97/255), Color(red: 24/255, green: 190/255, blue: 80/255)],
         1007),
        ("Calendar", "calendar",
         [.red, .orange],
         1005),
        ("Mail", "envelope.fill",
         [.blue, .cyan],
         1000),
        ("Reminders", "list.bullet",
         [.orange, .yellow],
         1005),
        ("FaceTime", "video.fill",
         [Color(red: 32/255, green: 206/255, blue: 97/255), Color(red: 24/255, green: 190/255, blue: 80/255)],
         1002),
        ("Weather", "cloud.rain.fill",
         [.blue, .cyan],
         1307),
        ("Photos", "photo.fill",
         [.purple, .indigo],
         1118),
        ("Clock", "alarm.fill",
         [.orange, .red],
         1005)
    ]
    
    init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.wasActiveBeforeBackground = (self.timer != nil || self.distractionTimer != nil)
                self.pauseGame()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.wasActiveBeforeBackground {
                    self.resumeGame()
                }
            }
        }
    }
    
    func startGame() {
        endGameReason = .timeUp
        gameActive = true
        currentNotificationInterval = 2.0
        distractionProbability = 0.2
        
        stopGame()
        gameTime = 60
        score = 0
        focusStreak = 0
        bestStreak = 0
        totalFocusTime = 0
        scoreMultiplier = 1
        lastFocusState = false
        position = CGPoint(x: UIScreen.main.bounds.width / 2,
                           y: UIScreen.main.bounds.height / 2)
        
        startRandomMovement()
        startDistractions()
        startFocusStreakTimer()
        startGameTimer()
    }
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            Task { @MainActor in
                if self.gameTime > 0 {
                    self.gameTime -= 1
                } else {
                    self.endGame()
                }
            }
        }
    }
    
    private func endGame() {
        gameActive = false
        stopGame()
    }
    
    func pauseGame() {
        isPaused = true
        timer?.invalidate()
        distractionTimer?.invalidate()
        focusStreakTimer?.invalidate()
        gameTimer?.invalidate()
        timer = nil
        distractionTimer = nil
        focusStreakTimer = nil
        gameTimer = nil
    }
    
    func resumeGame() {
        isPaused = false
        startRandomMovement()
        startDistractions()
        startFocusStreakTimer()
        startGameTimer()
    }
    
    func stopGame() {
        wasActiveBeforeBackground = false
        pauseGame()
        distractions.removeAll()
        timer?.invalidate()
        distractionTimer?.invalidate()
        focusStreakTimer?.invalidate()
        gameTimer?.invalidate()
        timer = nil
        distractionTimer = nil
        focusStreakTimer = nil
        gameTimer = nil
    }
    
    func updateGazeStatus(_ isGazing: Bool) {
        if lastFocusState && !isGazing {
            let streakPenalty = min(Int(focusStreak), 10)
            score = max(0, score - streakPenalty)
            scoreMultiplier = 1
        }
        
        isGazingAtObject = isGazing
        if !isGazing {
            if focusStreak > bestStreak {
                bestStreak = focusStreak
            }
            focusStreak = 0
        }
        
        lastFocusState = isGazing
    }
    
    private func startRandomMovement() {
        let speed: CGFloat = 3.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                let screenSize = UIScreen.main.bounds
                let ballSize: CGFloat = 100
                
                var newX = self.position.x + (self.moveDirection.x * speed)
                var newY = self.position.y + (self.moveDirection.y * speed)
                
                if newX <= ballSize/2 || newX >= screenSize.width - ballSize/2 {
                    self.moveDirection.x *= -1
                    newX = self.position.x + (self.moveDirection.x * speed)
                }
                if newY <= ballSize/2 || newY >= screenSize.height - ballSize/2 {
                    self.moveDirection.y *= -1
                    newY = self.position.y + (self.moveDirection.y * speed)
                }
                
                self.position = CGPoint(x: newX, y: newY)
            }
        }
    }
    
    private func startDistractions() {
        distractionTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
            let baseProb = 0.15
            let timeBonus = (60.0 - self.gameTime) * 0.003
            let probability = min(baseProb + timeBonus, 0.4)
            
                if Double.random(in: 0...1) < probability {
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    
                    let notificationContent = self.notificationData.randomElement()!
                    let newDistraction = Distraction(
                        position: CGPoint(
                            x: CGFloat.random(in: 150...(screenWidth-150)),
                            y: CGFloat.random(in: 100...(screenHeight-100))
                        ),
                        title: notificationContent.title,
                        message: AppMessages.randomMessage(for: notificationContent.title),
                        appIcon: notificationContent.icon,
                        iconColors: notificationContent.colors,
                        soundID: notificationContent.sound
                    )
                    
                    withAnimation {
                        self.distractions.append(newDistraction)
                        if self.distractions.count > 3 {
                            self.distractions.removeFirst()
                        }
                    }
                    
                    if UIApplication.shared.applicationState == .active {
                        AudioServicesPlaySystemSound(notificationContent.sound)
                    }
                }
            }
        }
    }
    
    private func startFocusStreakTimer() {
        focusStreakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                guard self.isGazingAtObject else { return }
                
                self.focusStreak += 1
                self.totalFocusTime += 1
                if self.focusStreak > self.bestStreak {
                    self.bestStreak = self.focusStreak
                }
                self.updateScore()
            }
        }
    }
    
    private func updateScore() {
        score += 1 * scoreMultiplier
        
        if Int(focusStreak) % 5 == 0 {
            scoreMultiplier = min(scoreMultiplier + 1, 3)
        }
        
        if Int(focusStreak) % 10 == 0 {
            score += 5
        }
    }
    
    func handleDistractionTap() {
        
        endGameReason = .distractionTap
        gameActive = false
        stopGame()
    }
}
