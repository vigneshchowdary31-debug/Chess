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
            // highlight selected or legal
            if isSelected {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Theme.selection, lineWidth: 4)
                    .padding(2)
            } else if legalMove {
                Circle()
                    .fill(Theme.legalMove)
                    .frame(width: 24, height: 24)
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
        return isLight ? Theme.lightSquare : Theme.darkSquare
    }
}
