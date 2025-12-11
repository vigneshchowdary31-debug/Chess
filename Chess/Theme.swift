
import SwiftUI

struct Theme {
    static let lightSquare = Color(red: 0.93, green: 0.85, blue: 0.72) // Light wood
    static let darkSquare = Color(red: 0.70, green: 0.53, blue: 0.39)  // Dark wood
    static let background = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.2, green: 0.2, blue: 0.3)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let selection = Color.yellow.opacity(0.8)
    static let legalMove = Color.blue.opacity(0.5)
    static let accent = Color(red: 0.8, green: 0.6, blue: 0.4)
    
    static let whitePiece = Color.white
    static let blackPiece = Color.black
    
    // Glassmorphism background for panels
    static let panelBackground = Material.ultraThinMaterial
}
