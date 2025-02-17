//
//  VideoContent.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 22/01/25.
//

import SwiftUI

/// A model representing video content for distraction elements.
///
/// Each video content includes:
/// - Title and username
/// - Description text
/// - Visual elements (gradients, emojis, symbols)
struct VideoContent: Identifiable {
    let id = UUID()
    let title: String
    let username: String
    let description: String
    let gradientColors: [Color]
    let emojis: [String]
    let symbols: [String]
}
