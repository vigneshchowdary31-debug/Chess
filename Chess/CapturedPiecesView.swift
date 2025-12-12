//
//  CapturedPiecesView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.

import SwiftUI

struct CapturedPiecesView: View {
    let pieces: [Piece]
    let color: PieceColor
    @AppStorage("boardTheme") var boardTheme = BoardTheme.classic
    @AppStorage("pieceSet") var pieceSet = PieceSet.standard
    
    init(pieces: [Piece], color: PieceColor) {
        self.pieces = pieces
        self.color = color
    }
    
    var body: some View {
        let filteredPieces = pieces.filter { $0.color == color }
        
        HStack(spacing: -8) {
            ForEach(filteredPieces) { piece in
                PieceView(piece: piece)
                    .frame(width: 20, height: 20)
                    .transition(.scale)
            }
        }
        .frame(height: 24)
        .padding(.horizontal, 8)
        .background(
            Capsule()
                .fill(Theme.panelBackground)
                .opacity(0.3)
        )
    }
}
