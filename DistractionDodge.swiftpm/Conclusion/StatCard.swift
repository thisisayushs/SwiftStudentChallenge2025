//
//  StatCard.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 11/02/25.
//

import SwiftUI

/// A view component that displays a single game statistic with an icon.
///
/// StatCard provides a consistent visual style for displaying game statistics with:
/// - Icon representation
/// - Value display
/// - Descriptive title
/// - Glass-like visual effects
///
/// Usage:
/// ```swift
/// StatCard(
///     title: "Total Focus",
///     value: "120s",
///     icon: "clock.fill"
/// )
/// ```
struct StatCard: View {
    // MARK: - Properties
    
    /// Title describing the statistic
    let title: String
    
    /// Value of the statistic to display
    let value: String
    
    /// SF Symbol name for the icon
    let icon: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 150)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
    }
}
