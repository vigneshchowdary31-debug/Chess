//
//  TileView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct TileView: View {
    let position: Position
    let piece: Piece?
    let isSelected: Bool
    let legalMove: Bool
    var pieceNamespace: Namespace.ID
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
            // highlight selected or legal
            if isSelected {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.yellow)
                    .padding(4)
            } else if legalMove {
                Circle()
                    .fill(Color.red.opacity(0.7))
                    .frame(width: 20, height: 20)
            }
            if let piece = piece {
                PieceView(piece: piece)
                    .matchedGeometryEffect(id: piece.id, in: pieceNamespace)
                    .padding(6)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var backgroundColor: Color {
        let isLight = (position.file + position.rank) % 2 == 0
        return isLight ? Color(.systemGray6) : Color(.systemGreen).opacity(0.9)
    }
}
