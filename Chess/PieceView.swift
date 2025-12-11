//
//  PieceView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct PieceView: View {
    let piece: Piece
    @AppStorage("pieceSet") var pieceSet = PieceSet.standard
    @AppStorage("boardTheme") var boardTheme = BoardTheme.classic
    
    var body: some View {
        Group {
            if pieceSet == .standard {
                Text(symbol)
                    .font(.system(size: 100)) // Use large font, let it scale down
                    .minimumScaleFactor(0.1)
                    .foregroundColor(pieceColor)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                PieceShape(type: piece.type, set: pieceSet)
                    .fill(pieceColor)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
    
    var symbol: String {
        switch piece.type {
        case .pawn: return "♟\u{FE0E}"
        case .rook: return "♜\u{FE0E}"
        case .knight: return "♞\u{FE0E}"
        case .bishop: return "♝\u{FE0E}"
        case .queen: return "♛\u{FE0E}"
        case .king: return "♚\u{FE0E}"
        }
    }
    
    var pieceColor: Color {
        return piece.color == .white ? Theme.whitePiece : Theme.blackPiece
    }
}
