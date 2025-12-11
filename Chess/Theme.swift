//
//  Theme.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

enum BoardTheme: String, CaseIterable, Identifiable {
    case classic = "Classic Wood"
    case blue = "Blue/Gray Minimal"
    case dark = "Dark Mode Board"
    case neon = "Neon Theme"
    
    var id: String { self.rawValue }
}

struct Theme {
    // Current theme retrieval
    static var currentTheme: BoardTheme {
        let saved = UserDefaults.standard.string(forKey: "boardTheme") ?? BoardTheme.classic.rawValue
        return BoardTheme(rawValue: saved) ?? .classic
    }
    
    static var lightSquare: Color {
        switch currentTheme {
        case .classic: return Color(red: 0.93, green: 0.85, blue: 0.72)
        case .blue: return Color(red: 0.9, green: 0.95, blue: 1.0)
        case .dark: return Color(red: 0.3, green: 0.3, blue: 0.35)
        case .neon: return Color(red: 0.1, green: 0.1, blue: 0.1)
        }
    }
    
    static var darkSquare: Color {
        switch currentTheme {
        case .classic: return Color(red: 0.70, green: 0.53, blue: 0.39)
        case .blue: return Color(red: 0.5, green: 0.6, blue: 0.7)
        case .dark: return Color(red: 0.15, green: 0.15, blue: 0.2)
        case .neon: return Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.3)
        }
    }
    
    static var background: LinearGradient {
        let isDark = UserDefaults.standard.object(forKey: "isDarkMode") == nil ? true : UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if !isDark {
            return LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.95), Color(white: 0.85)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        switch currentTheme {
        case .classic:
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.2, green: 0.2, blue: 0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blue:
            return LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(red: 0.9, green: 0.95, blue: 1.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .dark:
            return LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .neon:
             return LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.05, green: 0.0, blue: 0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    static var selection: Color {
        switch currentTheme {
        case .neon: return Color.green
        default: return Color.yellow.opacity(0.8)
        }
    }
    
    static var legalMove: Color {
        switch currentTheme {
        case .neon: return Color.pink.opacity(0.8)
        default: return Color.blue.opacity(0.5)
        }
    }
    
    static var lastMoveHighlight: Color {
        switch currentTheme {
        case .neon: return Color.purple
        default: return Color.yellow.opacity(0.5)
        }
    }
    
    static var accent: Color {
        switch currentTheme {
        case .classic: return Color(red: 0.8, green: 0.6, blue: 0.4)
        case .blue: return Color.blue
        case .dark: return Color.gray
        case .neon: return Color.green
        }
    }
    
    static var whitePiece: Color {
        switch currentTheme {
        case .neon: return Color.white
        default: return Color.white
        }
    }
    
    static var blackPiece: Color {
        switch currentTheme {
        case .neon: return Color.green // Neon green for black pieces in neon theme? Or maybe Pink? Let's go with Green/Pink for Neon theme.
        case .dark: return Color.black
        default: return Color.black
        }
    }
    
    // Glassmorphism background for panels
    static var panelBackground: Material {
        return .ultraThinMaterial
    }
}
