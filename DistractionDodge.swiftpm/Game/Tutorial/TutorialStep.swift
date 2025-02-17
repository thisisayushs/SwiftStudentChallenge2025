//
//  TutorialStep.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import Foundation

/// A model representing a single step in the tutorial sequence.
///
/// TutorialStep encapsulates all information needed for a tutorial step:
/// - Title and descriptions
/// - Type of scoring mechanic being demonstrated
/// - Unique identifier for step tracking
///
/// Usage:
/// ```swift
/// let step = TutorialStep(
///     title: "Basic Focus",
///     description: ["Look at the circle", "Follow it with your eyes"],
///     scoringType: .introduction
/// )
/// ```
struct TutorialStep: Identifiable {
    // MARK: - Properties
    
    /// Unique identifier for the step
    let id = UUID()
    
    /// Title displayed at the top of the step
    let title: String
    
    /// Array of description texts shown during the step
    let description: [String]
    
    /// Type of scoring mechanic being demonstrated
    let scoringType: ScoringType
}
