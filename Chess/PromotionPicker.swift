//
//  PromotionPicker.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct PromotionPicker: View {
    var onPick: (PieceType) -> Void
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Promote to")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)
                
                HStack(spacing: 15) {
                    promotionButton(type: .queen, label: "Queen", icon: "♕")
                    promotionButton(type: .rook, label: "Rook", icon: "♖")
                    promotionButton(type: .bishop, label: "Bishop", icon: "♗")
                    promotionButton(type: .knight, label: "Knight", icon: "♘")
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Theme.panelBackground)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding()
        }
    }
    
    private func promotionButton(type: PieceType, label: String, icon: String) -> some View {
        Button(action: { pick(type) }) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 50))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                Text(label)
                    .font(.caption)
                    .bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func pick(_ type: PieceType) {
        onPick(type)
        presentation.wrappedValue.dismiss()
    }
}
