//
//  TutorialView.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A comprehensive tutorial view that guides users through the game mechanics.
///
/// TutorialView provides:
/// - Step-by-step introduction to game features
/// - Interactive demonstrations
/// - Practice sessions for core mechanics
/// - Visual feedback and instructions
///
/// The tutorial covers:
/// - Basic eye tracking and focus
/// - Dealing with distractions
/// - Scoring system
/// - Multipliers and bonuses
/// - Penalties
struct TutorialView: View {
    @State private var currentStep = 0
    @State private var showContentView = false
    @State private var demoPosition = CGPoint(x: UIScreen.main.bounds.width / 2,
                                              y: UIScreen.main.bounds.height * 0.15)
    @State private var demoIsGazing = false
    @State private var demoScore = 0
    @State private var demoStreak = 0
    @State private var showScoreCard = false
    @State private var showMultiplierCard = false
    @State private var showPenaltyCard = false
    @State private var showDemoDistraction = false
    @State private var demoMultiplier = 1
    @State private var showScoreIncrementIndicator = false
    @State private var showBonusIndicator = false
    @State private var showPenaltyIndicator = false
    @State private var elapsedTime: Int = 0
    @State private var streakTime: Int = 0
    @State private var penaltyTimer: Timer? = nil
    
    @State private var isMovingBall = false
    @State private var moveDirection = CGPoint(x: 1, y: 1)
    @State private var hasDemonstratedFollowing = false
    @State private var showNextButton = false
    @State private var customPosition = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                y: UIScreen.main.bounds.height * 0.15)
    @State private var nextButtonScale: CGFloat = 1.0
    @State private var isNavigating = false
    @GestureState private var dragOffset: CGFloat = 0
    @State private var showSkipAlert = false
    @State private var penaltyScreenAppearCount = 0
    
    
    private let gradientColors: [(start: Color, end: Color)] = [
        (.black.opacity(0.8), .indigo.opacity(0.2)),
        (.black.opacity(0.8), .purple.opacity(0.2)),
        (.black.opacity(0.8), .cyan.opacity(0.2)),
        (.black.opacity(0.8), .blue.opacity(0.2)),
        (.black.opacity(0.8), .indigo.opacity(0.2)),
        (.black.opacity(0.8), .purple.opacity(0.2))
    ]
    
    let tutorialSteps = [
        TutorialStep(
            title: "Prepare to Train Your Focus",
            description: [
                "Position your device steadily so your face is clearly visible to the camera.",
                "Look at the circle until it starts glowing.",
                "Now follow the moving circle with your eyes.",
                "Great! You've mastered the basics. Tap 'Next' to continue."
            ],
            scoringType: .introduction
        ),
        TutorialStep(
            title: "Stay Focused Despite Distractions",
            description: [
                "Keep your eyes on the moving circle while notifications appear.",
                "Remember: Looking at or tapping notifications ends your training.",
                "The most challenging part will be resisting the urge to tap interesting notifications."
            ],
            scoringType: .distractions
        ),
        TutorialStep(
            title: "Scoring",
            description: [
                "Every second of focus counts! Watch your score grow as you maintain your gaze."
            ],
            scoringType: .baseScoring
        ),
        TutorialStep(
            title: "Score Multipliers",
            description: [
                "Keep focusing to increase your multiplier! Every 5 seconds, your score multiply.",
            ],
            scoringType: .multiplier
        ),
        TutorialStep(
            title: "Streak Bonus",
            description: [
                "Maintain focus for 10 seconds to earn bonus points!",
            ],
            scoringType: .streakBonus
        ),
        TutorialStep(
            title: "Breaking Focus",
            description: [
                "Be careful! Looking away has consequences.",
            ],
            scoringType: .penalty
        )
    ]
    
    private func navigate(forward: Bool) {
        if !isNavigating {
            isNavigating = true
            
            withAnimation(.easeOut) {
                showNextButton = false
                nextButtonScale = 1.0
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                if forward && currentStep < tutorialSteps.count - 1 {
                    currentStep += 1
                } else if !forward && currentStep > 0 {
                    currentStep -= 1
                }
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNavigating = false
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        gradientColors[currentStep].start,
                        gradientColors[currentStep].end
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: currentStep)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showSkipAlert = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    
                    Text(tutorialSteps[currentStep].title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id("title\(currentStep)")
                    
                    
                    Text(currentStep == 0 ?
                         tutorialSteps[0].description[isMovingBall ? 2 :
                                                        (hasDemonstratedFollowing ? 3 :
                                                            (demoIsGazing ? 1 : 0))] :
                            tutorialSteps[currentStep].description[0])
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id("description\(currentStep)")
                    .animation(.easeInOut, value: isMovingBall)
                    .animation(.easeInOut, value: hasDemonstratedFollowing)
                    .animation(.easeInOut, value: demoIsGazing)
                    
                    
                    VStack(spacing: 80) {
                        switch tutorialSteps[currentStep].scoringType {
                        case .introduction:
                            ZStack {
                                
                                EyeTrackingView { isGazing in
                                    if self.demoIsGazing != isGazing {
                                        self.demoIsGazing = isGazing
                                        if isGazing && !isMovingBall && !hasDemonstratedFollowing {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    isMovingBall = true
                                                    self.startBallMovement()
                                                }
                                            }
                                            
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                    isMovingBall = false
                                                    
                                                    customPosition = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                                             y: UIScreen.main.bounds.height * 0.15)
                                                    
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        withAnimation(.easeInOut) {
                                                            hasDemonstratedFollowing = true
                                                            
                                                            showNextButton = true
                                                            withAnimation(
                                                                .easeInOut(duration: 0.5)
                                                                .repeatForever(autoreverses: true)
                                                            ) {
                                                                nextButtonScale = 1.1
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                VStack(spacing: 60) {
                                    
                                    HStack {
                                        Image(systemName: "eye")
                                            .font(.system(size: 24))
                                        Text(isMovingBall ? "Keep following the circle" : "Gaze Detected")
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                    }
                                    .foregroundColor(demoIsGazing ? .green : .white.opacity(0.5))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.15))
                                    )
                                    .shadow(color: demoIsGazing ? .green.opacity(0.5) : .clear, radius: 10)
                                    
                                    Spacer()
                                    
                                    
                                    MainCircle(isGazingAtTarget: demoIsGazing,
                                               position: customPosition)
                                    .padding(.bottom, 100)
                                    
                                    Spacer()
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.top, 40)
                                
                                
                            }
                            .id("introduction\(currentStep)_\(penaltyScreenAppearCount)")
                            .onAppear {
                                
                                demoIsGazing = false
                                isMovingBall = false
                                hasDemonstratedFollowing = false
                                showNextButton = false
                                nextButtonScale = 1.0
                                customPosition = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                         y: UIScreen.main.bounds.height * 0.15)
                            }
                            
                            
                        case .baseScoring:
                            VStack(spacing: 40) {
                                Text("Score: \(demoScore)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        .linearGradient(
                                            colors: [.white, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                MainCircle(isGazingAtTarget: true,
                                           position: CGPoint(x: UIScreen.main.bounds.width / 2,
                                                             y: UIScreen.main.bounds.height * 0.22))
                                .overlay(
                                    Text("+1")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            .linearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                        .modifier(FloatingScoreModifier(isShowing: showScoreIncrementIndicator))
                                )
                                .onAppear {
                                    startBaseScoring()
                                }
                            }
                            .id("scoring\(currentStep)")
                            
                        case .multiplier:
                            VStack(spacing: 40) {
                                HStack(spacing: 30) {
                                    // Score display
                                    VStack(alignment: .center) {
                                        Text("Score")
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                        Text("\(demoScore)")
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    
                                    VStack(alignment: .center) {
                                        Text("Time")
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                        Text("\(elapsedTime)s")
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    
                                    VStack(alignment: .center) {
                                        Text("Multiplier")
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                        Text("×\(demoMultiplier)")
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundStyle(
                                                .linearGradient(
                                                    colors: [.orange, .red],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    }
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.15))
                                )
                                
                                MainCircle(isGazingAtTarget: true,
                                           position: CGPoint(x: UIScreen.main.bounds.width / 2,
                                                             y: UIScreen.main.bounds.height * 0.20))
                                .onAppear {
                                    startMultiplierDemo()
                                }
                            }
                            .id("multiplier\(currentStep)")
                            
                        case .streakBonus:
                            VStack(spacing: 40) {
                                HStack(spacing: 30) {
                                    
                                    VStack(alignment: .center) {
                                        Text("Score")
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                        Text("\(demoScore)")
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    
                                    VStack(alignment: .center) {
                                        Text("Streak")
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                        Text("\(demoStreak)s")
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundStyle(
                                                .linearGradient(
                                                    colors: [.yellow, .orange],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    }
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.15))
                                )
                                
                                if showBonusIndicator {
                                    Text("+5 BONUS")
                                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                                        .foregroundStyle(
                                            .linearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .modifier(StyledTextEffect(isShowing: showBonusIndicator, style: .bonus))
                                }
                                
                                MainCircle(isGazingAtTarget: true,
                                           position: CGPoint(x: UIScreen.main.bounds.width / 2,
                                                             y: UIScreen.main.bounds.height * 0.20))
                                .scaleEffect(showBonusIndicator ? 1.1 : 1.0)
                                .onAppear {
                                    startStreakBonusDemo()
                                }
                            }
                            .id("streak\(currentStep)")
                            
                            
                        case .penalty:
                            VStack(spacing: 40) {
                                HStack(spacing: 30) {
                                    
                                    VStack(alignment: .center) {
                                        Text("Score")
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                        Text("\(demoScore)")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    
                                    VStack(alignment: .center) {
                                        Text("Penalty")
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                        Text("-\(min(demoStreak, 10))")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundStyle(
                                                .linearGradient(
                                                    colors: [.red, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    }
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.15))
                                )
                                
                                if showPenaltyIndicator {
                                    Text("Focus Lost")
                                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                                        .foregroundColor(.red)
                                        .transition(.scale.combined(with: .opacity))
                                }
                                
                                MainCircle(isGazingAtTarget: !showPenaltyIndicator,
                                           position: CGPoint(x: geometry.size.width / 2,
                                                             y: geometry.size.height / 5))
                            }
                            .id("penalty\(currentStep)_\(penaltyScreenAppearCount)")
                            .onAppear {
                                penaltyScreenAppearCount += 1
                                showPenaltyIndicator = false
                                demoScore = 30
                                demoStreak = 8
                                startPenaltyDemo()
                            }
                            
                            
                            
                        case .distractions:
                            ZStack {
                                
                                EyeTrackingView { isGazing in
                                    self.demoIsGazing = isGazing
                                }
                                
                                VStack(spacing: 60) {
                                    
                                    HStack {
                                        Image(systemName: "eye")
                                            .font(.system(size: 24))
                                        Text("Keep Following")
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                    }
                                    .foregroundColor(demoIsGazing ? .green : .white.opacity(0.5))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.15))
                                    )
                                    .shadow(color: demoIsGazing ? .green.opacity(0.5) : .clear, radius: 10)
                                    
                                    Spacer()
                                    
                                    
                                    MainCircle(isGazingAtTarget: demoIsGazing,
                                               position: customPosition)
                                    .padding(.bottom, 100)
                                    
                                    Spacer()
                                }
                                
                                
                                if showDemoDistraction {
                                    NotificationView(
                                        distraction: Distraction(
                                            position: CGPoint(x: UIScreen.main.bounds.width * 0.7,
                                                              y: UIScreen.main.bounds.height * 0.4),
                                            title: "Messages",
                                            message: "🎮 Game night tonight?",
                                            appIcon: "message.fill",
                                            iconColors: [.green, .blue],
                                            soundID: 1007
                                        ),
                                        index: 0
                                    )
                                    .environmentObject(AttentionViewModel())
                                    .allowsHitTesting(false)
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                                }
                            }
                           
                            .onAppear {
                                
                                if !isMovingBall {
                                    isMovingBall = true
                                    startBallMovement()
                                }
                                
                                startDistractionDemo()
                            }
                            .id("distractions\(currentStep)")
                            
                            
                        }
                    }
                    .frame(height: geometry.size.height * 0.4)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        if currentStep > 0 {
                            Button(action: { navigate(forward: false) }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Previous")
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.white.opacity(0.2)))
                            }
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .disabled(isNavigating)
                        }
                        
                        Button(action: {
                            if currentStep < tutorialSteps.count - 1 {
                                navigate(forward: true)
                            } else {
                                showContentView = true
                            }
                        }) {
                            HStack {
                                Text(currentStep == tutorialSteps.count - 1 ? "Start Game" : "Next")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                if currentStep < tutorialSteps.count - 1 {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.white.opacity(0.2)))
                            .scaleEffect(showNextButton ? nextButtonScale : 1.0)
                        }
                        .disabled(isNavigating)
                    }
                    .padding(.bottom, 50)
                }
                .padding()
                
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if !isNavigating {
                                if value.translation.width > threshold {
                                    navigate(forward: false)
                                } else if value.translation.width < -threshold {
                                    navigate(forward: true)
                                }
                            }
                        }
                )
                
                
                if showSkipAlert {
                    AlertView(
                        title: "Skip Tutorial?",
                        message: "You are about to skip the tutorial. You will be taken directly to the game.",
                        primaryAction: {
                            showContentView = true
                        },
                        secondaryAction: {},
                        isPresented: $showSkipAlert
                    )
                }
            }
            .animation(.easeInOut, value: showSkipAlert)
        }
        .onChange(of: currentStep) { oldValue, newValue in
            
            resetStateForStep(newValue)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .fullScreenCover(isPresented: $showContentView) {
            ContentView()
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentStep)
    }
    
    private func startBaseScoring() {
        
        demoScore = 0
        showNextButton = false
        nextButtonScale = 1.0
        var hasStartedBounce = false
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                guard tutorialSteps[currentStep].scoringType == .baseScoring else {
                    timer.invalidate()
                    return
                }
                
                withAnimation {
                    demoScore += 1
                    showScoreIncrementIndicator = true
                    
                    if demoScore > 10 {
                        demoScore = 0
                    }
                    
                    if demoScore == 0 && !hasStartedBounce {
                        hasStartedBounce = true
                        showNextButton = true
                        withAnimation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            nextButtonScale = 1.1
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showScoreIncrementIndicator = false
                        }
                    }
                }
            }
        }
    }
    
    private func startMultiplierDemo() {
        
        demoScore = 0
        demoMultiplier = 1
        elapsedTime = 0
        showNextButton = false
        nextButtonScale = 1.0
        var hasStartedBounce = false
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                guard tutorialSteps[currentStep].scoringType == .multiplier else {
                    timer.invalidate()
                    return
                }
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    elapsedTime += 1
                    
                    if elapsedTime >= 60 {
                        elapsedTime = 0
                        demoScore = 0
                        demoMultiplier = 1
                    }
                    
                    if elapsedTime % 5 == 0 && demoMultiplier < 3 {
                        demoMultiplier += 1
                        
                        if !hasStartedBounce {
                            hasStartedBounce = true
                            showNextButton = true
                            withAnimation(
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                            ) {
                                nextButtonScale = 1.1
                            }
                        }
                    }
                    
                    demoScore += demoMultiplier
                }
            }
        }
    }
    
    private func startStreakBonusDemo() {
        
        demoScore = 0
        demoStreak = 0
        streakTime = 0
        showBonusIndicator = false
        showNextButton = false
        nextButtonScale = 1.0
        var hasStartedBounce = false
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                guard tutorialSteps[currentStep].scoringType == .streakBonus else {
                    timer.invalidate()
                    return
                }
                
                streakTime += 1
                demoStreak += 1
                demoScore += 1
                
                
                if streakTime >= 60 {
                    streakTime = 0
                    demoScore = 0
                    demoStreak = 0
                }
                
                
                if !hasStartedBounce && streakTime == 0 {
                    hasStartedBounce = true
                    showNextButton = true
                    withAnimation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        nextButtonScale = 1.1
                    }
                }
                
                if demoStreak % 10 == 0 {
                    withAnimation(.spring(duration: 0.5)) {
                        showBonusIndicator = true
                        demoScore += 5
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showBonusIndicator = false
                        }
                    }
                }
            }
        }
    }
    
    private func startPenaltyDemo() {
        demoScore = 30
        demoStreak = 8
        showPenaltyIndicator = false
        showNextButton = false
        nextButtonScale = 1.0
        var cycleCount = 0
        var hasStartedBounce = false
        
        func runPenaltyCycle() {
            withAnimation(.easeInOut(duration: 0.5)) {
                showPenaltyIndicator = true
                demoScore = max(0, demoScore - min(demoStreak, 10))
                
                
                if !hasStartedBounce && cycleCount > 0 {
                    hasStartedBounce = true
                    showNextButton = true
                    withAnimation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        nextButtonScale = 1.1
                    }
                }
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                cycleCount += 1
                demoScore = 30
                demoStreak = 8
                withAnimation {
                    showPenaltyIndicator = false
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    guard tutorialSteps[currentStep].scoringType == .penalty else { return }
                    runPenaltyCycle()
                }
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            runPenaltyCycle()
        }
    }
    
    private func startDistractionDemo() {
        var distractionCount = 0
        isMovingBall = true
        startBallMovement()
        showDemoDistraction = false
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            Task { @MainActor in
                guard currentStep == 1 && isMovingBall else {
                    timer.invalidate()
                    return
                }
                
                distractionCount += 1
                if distractionCount >= 3 {
                    timer.invalidate()
                    showDemoDistraction = false
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            isMovingBall = false
                            customPosition = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                     y: UIScreen.main.bounds.height * 0.15)
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            showNextButton = true
                            withAnimation(
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                            ) {
                                nextButtonScale = 1.1
                            }
                        }
                    }
                    return
                }
                
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showDemoDistraction = true
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut) {
                        showDemoDistraction = false
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showDemoDistraction = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func startBallMovement() {
        let speed: CGFloat = 2.0
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            Task { @MainActor in
                guard isMovingBall else {
                    timer.invalidate()
                    return
                }
                
                let ballSize: CGFloat = 100
                let screenSize = UIScreen.main.bounds
                
                var newX = self.customPosition.x + (self.moveDirection.x * speed)
                var newY = self.customPosition.y + (self.moveDirection.y * speed)
                
                if newX <= ballSize/2 || newX >= screenSize.width - ballSize/2 {
                    self.moveDirection.x *= -1
                    newX = self.customPosition.x + (self.moveDirection.x * speed)
                }
                if newY <= screenSize.height * 0.15 || newY >= screenSize.height * 0.4 {
                    self.moveDirection.y *= -1
                    newY = self.customPosition.y + (self.moveDirection.y * speed)
                }
                
                self.customPosition = CGPoint(x: newX, y: newY)
            }
        }
    }
    
    
    private func resetStateForStep(_ step: Int) {
        
        showNextButton = false
        nextButtonScale = 1.0
        
        
        showScoreIncrementIndicator = false
        showBonusIndicator = false
        showPenaltyIndicator = false
        showDemoDistraction = false
        
        
        switch tutorialSteps[step].scoringType {
        case .penalty:
            demoScore = 30
            demoStreak = 8
        case .baseScoring:
            demoScore = 0
            demoStreak = 0
        case .multiplier:
            demoScore = 0
            demoStreak = 0
            demoMultiplier = 1
            elapsedTime = 0
        case .streakBonus:
            demoScore = 0
            demoStreak = 0
            streakTime = 0
        default:
            demoScore = 0
            demoStreak = 0
        }
        
        if step == 0 || step == 1 {
            customPosition = CGPoint(x: UIScreen.main.bounds.width / 2,
                                     y: UIScreen.main.bounds.height * 0.15)
        }
        
        isMovingBall = false
    }
}
