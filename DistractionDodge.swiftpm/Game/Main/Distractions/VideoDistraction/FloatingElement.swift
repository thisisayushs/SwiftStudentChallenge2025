//
//  FloatingElement.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 22/01/25.
//

import Foundation

/// A model representing floating visual elements in video distractions.
///
/// Each element includes:
/// - Position and movement properties
/// - Visual transformation properties
/// - Content (emoji or symbol)
struct FloatingElement: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var rotation: Double
    let content: String
    var velocity: CGPoint
}
