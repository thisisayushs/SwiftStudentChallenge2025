//
//  ScoringType.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import Foundation

/// Defines the different types of scoring mechanics demonstrated in the tutorial.
///
/// ScoringType represents each major gameplay mechanic that needs to be taught:
/// - Basic focus mechanics (introduction)
/// - Core scoring system
/// - Advanced scoring features (multipliers, streaks)
/// - Penalties and distractions
///
/// Usage:
/// ```swift
/// let tutorialStep = TutorialStep(
///     title: "Basic Scoring",
///     description: [...],
///     scoringType: .baseScoring
/// )
/// ```
enum ScoringType {
    /// Initial focus mechanic introduction
    case introduction
    
    /// Basic point scoring system
    case baseScoring
    
    /// Score multiplier mechanics
    case multiplier
    
    /// Bonus points for maintaining streaks
    case streakBonus
    
    /// Score penalties for breaking focus
    case penalty
    
    /// Dealing with distraction elements
    case distractions
}
