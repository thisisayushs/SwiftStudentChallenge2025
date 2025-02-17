//
//  ScoringRuleCard.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A view component that displays a scoring rule or mechanic in the tutorial.
///
/// ScoringRuleCard provides a consistent layout for explaining game mechanics:
/// - Icon with gradient coloring
/// - Title and description text
/// - Custom background with gradient border
///
/// Usage:
/// ```swift
/// ScoringRuleCard(
///     title: "Base Scoring",
///     description: "Earn points for maintaining focus",
///     icon: "star.fill",
///     gradient: [.yellow, .orange]
/// )
/// ```
struct ScoringRuleCard: View {
    // MARK: - Properties
    
    /// Title text explaining the rule
    let title: String
    
    /// Detailed description of the rule
    let description: String
    
    /// SF Symbol name for the rule's icon
    let icon: String
    
    /// Gradient colors for icon and border
    let gradient: [Color]
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(
                    .linearGradient(
                        colors: gradient,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text(description)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.5) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
    }
}
