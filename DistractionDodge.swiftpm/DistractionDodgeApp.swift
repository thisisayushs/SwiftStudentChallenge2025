//
//  DistractionDodgeApp.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 28/12/24.
//

import SwiftUI

/// The main entry point for the Attention App.
///
/// This app structure configures the initial UI and app-wide settings:
/// - Sets OnboardingView as the root view
/// - Enables dark appearance for the entire application
/// - Manages the primary window group
@main
struct DistractionDodge: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .preferredColorScheme(.dark)
        }
    }
}
