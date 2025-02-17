//
//  Distraction.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 28/12/24.
//

import SwiftUI
import AVFoundation

/// A model representing a notification-style distraction in the game.
///
/// Distraction encapsulates all properties needed for interactive notification elements:
/// - Visual properties (position, icons, colors)
/// - Content (title and message)
/// - Sound effects
///
/// Usage:
/// ```swift
/// let distraction = Distraction(
///     position: CGPoint(x: 100, y: 100),
///     title: "New Message",
///     message: "Hey, check this out!",
///     appIcon: "message.fill",
///     iconColors: [.blue, .purple],
///     soundID: 1234
/// )
/// ```
struct Distraction: Identifiable {
    // MARK: - Properties
    
    /// Unique identifier for the distraction
    let id = UUID()
    
    /// Position on screen where the distraction appears
    var position: CGPoint
    
    /// Title text displayed in the notification
    var title: String
    
    /// Message content of the notification
    var message: String
    
    /// SF Symbol name for the app icon
    var appIcon: String
    
    /// Gradient colors for the app icon
    var iconColors: [Color]
    
    /// System sound ID for notification effects
    var soundID: SystemSoundID
}
