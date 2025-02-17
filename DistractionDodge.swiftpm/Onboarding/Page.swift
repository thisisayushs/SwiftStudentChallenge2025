//
//  Page.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 10/02/25.
//

import Foundation

/// A model representing a single page in the onboarding flow.
///
/// Each page contains educational content about focus and attention,
/// along with visual elements like emojis and SF Symbols to enhance
/// the learning experience.
///
/// Usage:
/// ```swift
/// let page = Page(
///     title: "Welcome",
///     content: ["First point", "Second point"],
///     sfSymbol: "brain.head.profile",
///     emoji: "🧠",
///     buttonText: "Continue"
/// )
/// ```
struct Page: Identifiable {
    let id = UUID()
    /// Unique identifier for the page
    // MARK: - Properties
    
    /// Main title displayed at the top of the page
    let title: String
    
    /// Array of content points to be displayed
    let content: [String]
    
    /// SF Symbol name used for visual representation
    let sfSymbol: String
    
    /// Emoji character used for visual emphasis
    let emoji: String
    
    /// Text displayed on the navigation button
    let buttonText: String
}
