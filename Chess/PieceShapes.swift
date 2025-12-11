//
//  PieceShapes.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

enum PieceSet: String, CaseIterable, Identifiable {
    case standard = "Standard (Text)"
    case alpha = "Alpha"
    case berlin = "Berlin"
    case staunton = "Staunton (Flat)"
    
    var id: String { self.rawValue }
}

struct PieceShape: Shape {
    let type: PieceType
    let set: PieceSet
    
    func path(in rect: CGRect) -> Path {
        _ = rect.width
        _ = rect.height
        let path = Path()
        
        // This is a placeholder for complex SVG paths. 
        // Real implementation would require thousands of lines for accurate SVGs of all sets.
        // For this demo, I will draw distinctive geometric representations for each set
        // or simplified symbols.
        
        switch set {
        case .standard:
            // Standard uses Text, so Shape not used, returning empty path
            return path
        case .alpha:
            return alphaPath(in: rect)
        case .berlin:
            return berlinPath(in: rect)
        case .staunton:
            return stauntonPath(in: rect)
        }
    }
    
    // MARK: - Alpha Style (Simplified, modern)
    func alphaPath(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        switch type {
        case .pawn:
            path.addEllipse(in: CGRect(x: w*0.3, y: h*0.3, width: w*0.4, height: h*0.4))
            path.addRect(CGRect(x: w*0.35, y: h*0.7, width: w*0.3, height: h*0.2))
        case .rook:
             path.addRect(CGRect(x: w*0.2, y: h*0.2, width: w*0.6, height: h*0.7))
             // castellation
             path.addRect(CGRect(x: w*0.2, y: h*0.1, width: w*0.15, height: h*0.1))
             path.addRect(CGRect(x: w*0.425, y: h*0.1, width: w*0.15, height: h*0.1))
             path.addRect(CGRect(x: w*0.65, y: h*0.1, width: w*0.15, height: h*0.1))
        case .knight:
            path.move(to: CGPoint(x: w*0.3, y: h*0.8))
            path.addLine(to: CGPoint(x: w*0.3, y: h*0.4))
            path.addLine(to: CGPoint(x: w*0.7, y: h*0.2)) // head
            path.addLine(to: CGPoint(x: w*0.8, y: h*0.4)) // snout
            path.addLine(to: CGPoint(x: w*0.6, y: h*0.5))
            path.addLine(to: CGPoint(x: w*0.7, y: h*0.8))
            path.closeSubpath()
        case .bishop:
            path.move(to: CGPoint(x: w*0.5, y: h*0.1))
            path.addLine(to: CGPoint(x: w*0.3, y: h*0.4))
            path.addLine(to: CGPoint(x: w*0.5, y: h*0.8))
            path.addLine(to: CGPoint(x: w*0.7, y: h*0.4))
            path.closeSubpath()
            // cross?
            path.move(to: CGPoint(x: w*0.5, y: h*0.1))
            path.addLine(to: CGPoint(x: w*0.5, y: h*0.25))
        case .queen:
            // Crown
            path.move(to: CGPoint(x: w*0.2, y: h*0.3))
            path.addLine(to: CGPoint(x: w*0.3, y: h*0.8))
            path.addLine(to: CGPoint(x: w*0.7, y: h*0.8))
            path.addLine(to: CGPoint(x: w*0.8, y: h*0.3))
            path.addLine(to: CGPoint(x: w*0.65, y: h*0.5))
            path.addLine(to: CGPoint(x: w*0.5, y: h*0.2))
            path.addLine(to: CGPoint(x: w*0.35, y: h*0.5))
            path.closeSubpath()
        case .king:
             path.addRect(CGRect(x: w*0.3, y: h*0.3, width: w*0.4, height: h*0.5))
             // cross on top
             path.move(to: CGPoint(x: w*0.5, y: h*0.1))
             path.addLine(to: CGPoint(x: w*0.5, y: h*0.3))
             path.move(to: CGPoint(x: w*0.4, y: h*0.2))
             path.addLine(to: CGPoint(x: w*0.6, y: h*0.2))
        }
        return path
    }
    
    // MARK: - Berlin (Minimialist, rounded)
    func berlinPath(in rect: CGRect) -> Path {
         var path = Path()
         let w = rect.width
         let h = rect.height
         
         // Using simpler geometric forms for berlin style
         switch type {
         case .pawn:
             path.addArc(center: CGPoint(x: w*0.5, y: h*0.6), radius: w*0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
             path.addRect(CGRect(x: w*0.25, y: h*0.6, width: w*0.5, height: h*0.2))
         case .rook:
             path.addRect(CGRect(x: w*0.2, y: h*0.3, width: w*0.6, height: h*0.5))
             path.addRect(CGRect(x: w*0.2, y: h*0.15, width: w*0.6, height: h*0.1))
         case .knight:
             path.move(to: CGPoint(x: w*0.3, y: h*0.8))
             path.addQuadCurve(to: CGPoint(x: w*0.7, y: h*0.3), control: CGPoint(x: w*0.1, y: h*0.5))
             path.addLine(to: CGPoint(x: w*0.7, y: h*0.8))
             path.closeSubpath()
         case .bishop:
             path.addEllipse(in: CGRect(x: w*0.35, y: h*0.2, width: w*0.3, height: h*0.6))
         case .queen:
             path.addEllipse(in: CGRect(x: w*0.2, y: h*0.3, width: w*0.6, height: h*0.5))
             path.addEllipse(in: CGRect(x: w*0.45, y: h*0.1, width: w*0.1, height: h*0.1))
         case .king:
             path.addRect(CGRect(x: w*0.3, y: h*0.3, width: w*0.4, height: h*0.5))
             path.move(to: CGPoint(x: w*0.5, y: h*0.1))
             path.addLine(to: CGPoint(x: w*0.5, y: h*0.3))
             path.move(to: CGPoint(x: w*0.4, y: h*0.2))
             path.addLine(to: CGPoint(x: w*0.6, y: h*0.2))
         }
         return path
    }
    
    // MARK: - Staunton 3D (Flat projection)
    func stauntonPath(in rect: CGRect) -> Path {
         var path = Path()
         let w = rect.width
         let h = rect.height
         
         // More detailed silhouette
         switch type {
         case .pawn:
             path.addEllipse(in: CGRect(x: w*0.38, y: h*0.25, width: w*0.24, height: h*0.24)) // head
             path.move(to: CGPoint(x: w*0.5, y: h*0.5))
             path.addCurve(to: CGPoint(x: w*0.3, y: h*0.8), control1: CGPoint(x: w*0.4, y: h*0.6), control2: CGPoint(x: w*0.3, y: h*0.7))
             path.addLine(to: CGPoint(x: w*0.7, y: h*0.8))
             path.addCurve(to: CGPoint(x: w*0.5, y: h*0.5), control1: CGPoint(x: w*0.7, y: h*0.7), control2: CGPoint(x: w*0.6, y: h*0.6))
         case .rook:
             path.addRect(CGRect(x: w*0.25, y: h*0.2, width: w*0.5, height: h*0.6))
             path.addRect(CGRect(x: w*0.2, y: h*0.1, width: w*0.6, height: h*0.15)) // top
         case .knight:
             // Classic horse head shape
             path.move(to: CGPoint(x: w*0.3, y: h*0.8))
             path.addLine(to: CGPoint(x: w*0.3, y: h*0.5))
             path.addQuadCurve(to: CGPoint(x: w*0.7, y: h*0.2), control: CGPoint(x: w*0.3, y: h*0.2)) // neck/head
             path.addLine(to: CGPoint(x: w*0.65, y: h*0.45)) // snout back
             path.addLine(to: CGPoint(x: w*0.75, y: h*0.5)) // snout tip
             path.addLine(to: CGPoint(x: w*0.5, y: h*0.6)) // jaw
             path.addLine(to: CGPoint(x: w*0.7, y: h*0.8))
             path.closeSubpath()
         case .bishop:
             // Mitre shape
             path.move(to: CGPoint(x: w*0.5, y: h*0.1))
             path.addCurve(to: CGPoint(x: w*0.3, y: h*0.5), control1: CGPoint(x: w*0.4, y: h*0.2), control2: CGPoint(x: w*0.3, y: h*0.3))
             path.addCurve(to: CGPoint(x: w*0.5, y: h*0.8), control1: CGPoint(x: w*0.3, y: h*0.7), control2: CGPoint(x: w*0.4, y: h*0.8))
             path.addCurve(to: CGPoint(x: w*0.7, y: h*0.5), control1: CGPoint(x: w*0.6, y: h*0.8), control2: CGPoint(x: w*0.7, y: h*0.7))
             path.addCurve(to: CGPoint(x: w*0.5, y: h*0.1), control1: CGPoint(x: w*0.7, y: h*0.3), control2: CGPoint(x: w*0.6, y: h*0.2))
         case .queen:
             path.move(to: CGPoint(x: w*0.5, y: h*0.1)) // top ball
             path.addCurve(to: CGPoint(x: w*0.3, y: h*0.3), control1: CGPoint(x: w*0.4, y: h*0.15), control2: CGPoint(x: w*0.3, y: h*0.2))
             path.addLine(to: CGPoint(x: w*0.4, y: h*0.8))
             path.addLine(to: CGPoint(x: w*0.6, y: h*0.8))
             path.addLine(to: CGPoint(x: w*0.7, y: h*0.3))
             path.addCurve(to: CGPoint(x: w*0.5, y: h*0.1), control1: CGPoint(x: w*0.7, y: h*0.2), control2: CGPoint(x: w*0.6, y: h*0.15))
         case .king:
            path.move(to: CGPoint(x: w*0.5, y: h*0.05)) // cross top
            path.addLine(to: CGPoint(x: w*0.5, y: h*0.2))
            path.move(to: CGPoint(x: w*0.42, y: h*0.12))
            path.addLine(to: CGPoint(x: w*0.58, y: h*0.12))
            // body
            path.move(to: CGPoint(x: w*0.5, y: h*0.2))
            path.addCurve(to: CGPoint(x: w*0.3, y: h*0.8), control1: CGPoint(x: w*0.2, y: h*0.5), control2: CGPoint(x: w*0.3, y: h*0.7))
            path.addLine(to: CGPoint(x: w*0.7, y: h*0.8))
            path.addCurve(to: CGPoint(x: w*0.5, y: h*0.2), control1: CGPoint(x: w*0.7, y: h*0.7), control2: CGPoint(x: w*0.8, y: h*0.5))
         }
         return path
    }
}
