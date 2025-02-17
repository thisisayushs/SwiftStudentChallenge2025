//
//  NotificationCategory.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 10/02/25.
//

import Foundation

/// Represents different types of notifications used as distractions in the focus training app.
///
/// Each case corresponds to a specific SF Symbol name that visually represents
/// the notification type during the training session.
///
/// Usage:
/// ```swift
/// let notification = NotificationCategory.message
/// let symbolName = notification.rawValue // Returns "message.badge.filled.fill"
/// ```
enum NotificationCategory: String, CaseIterable {
    /// Messaging app notification symbol
    case message = "message.badge.filled.fill"
    
    /// Email notification symbol
    case email = "envelope.badge.fill"
    
    /// Phone call notification symbol
    case phone = "phone.badge.fill"
    
    /// Social media notification symbol
    case social = "bubble.left.and.bubble.right.fill"
    
    /// Generic notification symbol
    case notification = "bell.badge.fill"
    
    /// Web browser notification symbol
    case browser = "safari.fill"
    
    /// Calendar event notification symbol
    case calendar = "calendar.badge.exclamationmark"
}
