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
        VStack(spacing: 20) {
            Text("Choose promotion")
                .font(.headline)
            HStack(spacing: 20) {
                Button(action: { pick(.queen) }) { Text("♕\nQueen").multilineTextAlignment(.center) }
                Button(action: { pick(.rook) }) { Text("♖\nRook").multilineTextAlignment(.center) }
                Button(action: { pick(.bishop) }) { Text("♗\nBishop").multilineTextAlignment(.center) }
                Button(action: { pick(.knight) }) { Text("♘\nKnight").multilineTextAlignment(.center) }
            }
            .font(.largeTitle)
        }
        .padding()
    }
    
    private func pick(_ type: PieceType) {
        onPick(type)
        presentation.wrappedValue.dismiss()
    }
}
